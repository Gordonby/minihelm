# Deploying the Sample App to your existing Kubernetes environment

#Prerequisite Azure Resources
# 1. Public Azure DNS Zone
$DOMAINSUFFIX="azdemo.co.uk"
# 2. Key Vault
$KVNAME='kv-aksbyo'
# 3. Application Gateway
$AGNAME='agw-AksByo'
# 4. AKS Cluster set up with CSI secret managed addon
$AKSNAME='aks-AksByo'
# 5. Resource Group where the AppGW and AKS are deployed
$RG='Automation-Actions-AksDeployCI'
# 6. Front and Backend Certificates created in AKV and AppGw

$KVTENANT=$(az account show --query tenantId -o tsv)

#Check the prerequiste certificates are there. (Name and Common Name should be the AppName)
az network application-gateway ssl-cert list -g $RG --gateway-name $AGNAME --query "[].name"
az network application-gateway root-cert list -g $RG --gateway-name $AGNAME --query "[].name"

az aks get-credentials -g $RG -n $AKSNAME --admin --overwrite-existing
$CSISECRET_CLIENTID=az aks show -g $RG --name $AKSNAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv

#Install the app
$app="openjdk-demo"
$DNSNAME="$app.$DOMAINSUFFIX"
helm upgrade --install $app ./samples/javatlsappv2 --set csisecrets.vaultname="$KVNAME",csisecrets.tenantId="$KVTENANT",csisecrets.clientId="$CSISECRET_CLIENTID",dnsname="$DNSNAME",nameOverride="$app",appgw.rootCertificateName="$app"

#Install the app again with a different name
$app="openjdk-kvssl"
$DNSNAME="$app.$DOMAINSUFFIX"
helm upgrade --install $app ./samples/javatlsappv2 --set csisecrets.vaultname="$KVNAME",csisecrets.tenantId="$KVTENANT",csisecrets.clientId="$CSISECRET_CLIENTID",dnsname="$DNSNAME",nameOverride="$app",appgw.rootCertificateName="$app"
