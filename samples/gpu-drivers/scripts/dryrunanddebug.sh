#!/usr/bin/env bash
set -uo pipefail

# This script should be executed on VM host in the directly as the deb packages
# the host will be mounted at /host, the debs will be copied to /mnt
# then the container will nsenter and install everything against the host.

set -x

echo "Script for NVIDIA driver install $GPU_DV"

echo "w debugging"
systemctl --version
ps -aux | grep nvidia-device-plugin
systemctl is-active nvidia-device-plugin
echo "Getting active system with nvidia"
systemctl list-units --state=active | grep nvidia
echo "Getting all systemctl with nvidia"
systemctl list-units --all | grep nvidia
echo "end w debugging"

open_devices="$(lsof /dev/nvidia* 2>/dev/null)"
nvidia_modprobe_active="$(systemctl is-active nvidia-modprobe)"
nvidia_device_plugin_active="$(systemctl is-active nvidia-device-plugin)"

echo "Open devices: $open_devices"
echo "nvidia-modprobe active: $nvidia_modprobe_active" #The nvidia-modprobe utility is used by user-space NVIDIA driver components to make sure the NVIDIA kernel module is loaded
echo "nvidia-device-plugin active: $nvidia_device_plugin_active" #The NVIDIA device plugin for Kubernetes

if [ -n "$open_devices" ]; then
    echo "--in if open-devices"
    if [ "$nvidia_modprobe_active" == "active" ]; then
        echo "Stopping nvidia-modprobe"
    else echo "modprobe not found to be active";
    fi
    if [ "$nvidia_device_plugin_active" == "active" ]; then
        echo "Stopping nvidia-device-plugin"
    else echo "nvidia device plugin not found to be active";
    fi
else echo "no open devices";
fi

GPU_DEST=/usr/local/nvidia
log_file_name="/var/log/nvidia-installer-$(date +%s).log"
KERNEL_NAME=$(uname -r)

#check for existing driver version
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

#uninstall existing driver
if [ -f "${GPU_DEST}/bin/nvidia-smi" ]; then
    if [ ! -z "$existing_version" ]; then
    echo "uninstalling driver version $existing_version to install version $GPU_DV"
    # nvidia uninstall requires kubelet to stop, throw a trap here as well as below
    # this covers existing driver case, outside the conditionals cover new drivers

        echo "DRYRUN: stopping kubelet"
        echo "DRYRUN: uninstalling nvidia drivers"
    fi
    if [ -z "$existing_version" ]; then
        echo "found nvidia-smi but failed to extract version, continuing with driver install."
        echo "this could lead to errors if previous module was not unloaded"
        echo "reboot/restarting kubelet fixes it."
    fi
fi

# !!DANGER!! but necessary because kubelet holds /dev/nvidia* open
# can't reinstall drivers without forcing that closed
echo "DRYRUN: stopping kubelet"
systemctl stop kubelet

echo "DRYRUN: running installer"
echo "DRYRUN: starting kubelet"
echo "finished installer"