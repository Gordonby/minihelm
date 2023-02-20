#!/usr/bin/env bash
set -uo pipefail

# This script should be executed on VM host in the directly as the deb packages
# the host will be mounted at /host, the debs will be copied to /mnt
# then the container will nsenter and install everything against the host.

set -x

echo "Script for NVIDIA driver install $GPU_DV"

GPU_DEST=/usr/local/nvidia
log_file_name="/var/log/nvidia-installer-$(date +%s).log"
KERNEL_NAME=$(uname -r)

echo "Check for existing driver version"
if [ -f "${GPU_DEST}/bin/nvidia-smi" ]; then
    echo "found existing nvidia-smi, checking version..."
    existing_version="$(nvidia-smi | grep "Driver Version" | cut -d' ' -f3)"
    if [ "$existing_version" == "$GPU_DV" ]; then
        echo "desired version $GPU_DV matches existing version $existing_version, exiting early"
        exit 0
    fi
fi

#Download the new driver
if [ ! -d "${GPU_DEST}" ]; then
    mkdir -p ${GPU_DEST}
fi

set -e

echo "downloading driver version $GPU_DV from nvidia website"
curl -fLS https://us.download.nvidia.com/tesla/$GPU_DV/NVIDIA-Linux-x86_64-${GPU_DV}.run -o ${GPU_DEST}/nvidia-drivers-${GPU_DV} --fail

set +e

echo "Checking and closing any processes that might be using the GPU"
open_devices="$(lsof /dev/nvidia* 2>/dev/null)"
nvidia_modprobe_active="$(systemctl is-active nvidia-modprobe)"
nvidia_device_plugin_active="$(systemctl is-active nvidia-device-plugin)"

echo "Open devices: $open_devices"
echo "nvidia-modprobe active: $nvidia_modprobe_active" #The nvidia-modprobe utility is used by user-spaceNVIDIA driver components to make sure the NVIDIA kernel module is loaded
echo "nvidia-device-plugin active: $nvidia_device_plugin_active" #The NVIDIA device plugin for Kubernetes

if [ -n "$open_devices" ]; then
    if [ "$nvidia_modprobe_active" == "active" ]; then
        echo "Stopping nvidia-modprobe"
        systemctl stop nvidia-modprobe
    fi
    if [ "$nvidia_device_plugin_active" == "active" ]; then
        echo "Stopping nvidia-device-plugin"
        systemctl stop nvidia-device-plugin
    fi
fi

echo "setting up 'finally' trap to restart kubelet"
trap 'systemctl restart kubelet' EXIT SIGINT SIGTERM

echo "stopping kubelet"
# Necessary because kubelet holds /dev/nvidia* open
# can't reinstall drivers without forcing that closed
systemctl stop kubelet

echo "Searching for nvidia device plugin processes"
PROCMATCHES=$(ps -aux | grep nvidia-device-plugin | grep -v grep -c)

if [ $PROCMATCHES == 1 ]; then
    echo "kill it"
    NVP=$(ps -aux | grep 'nvidia-device-plugin' | grep -v grep | awk '{ print $2 }')
    echo "------- pid $NVP"
    kill -9 $NVP
    ps -aux | grep nvidia-device-plugin | grep -v grep -c
else
    echo "Process not found"
fi

#set -e

#uninstall existing driver
if [ -f "${GPU_DEST}/bin/nvidia-smi" ]; then
    if [ ! -z "$existing_version" ]; then
        ${GPU_DEST}/bin/nvidia-uninstall --silent
    fi
    if [ -z "$existing_version" ]; then
        echo "found nvidia-smi but failed to extract version, continuing with driver install."
        echo "this could lead to errors if previous module was not unloaded"
        echo "reboot/restarting kubelet fixes it."
    fi
fi


ps -aux | grep nvidia-device-plugin | grep -v grep -c

echo "running installer"
sh $GPU_DEST/nvidia-drivers-$GPU_DV -s -k=$KERNEL_NAME --log-file-name=${log_file_name} -a --no-drm --dkms --utility-prefix="${GPU_DEST}" --opengl-prefix="${GPU_DEST}" 2>&1
nvidia-modprobe -u -c0
ldconfig
systemctl start kubelet
echo "finished installer"