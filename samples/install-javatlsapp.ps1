$NAMESP="default"
$CERTNAME="openjdk-demo-service"
$DOMAINSUFFIX="yourdomain.com"
$DOMAINPREFIX="openjdk-demo"
$AKSNAME=''
$RG=''
$KVNAME=''
$KVTENANT=$(az account show --query tenantId -o tsv)
$AGNAME=''

$DNSNAME="$DOMAINPREFIX.$DOMAINSUFFIX"

$CSISECRET_CLIENTID=az aks show -g $RG --name $AKSNAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv

helm upgrade --install e2esmokeapp ./samples/javatlsapp --set csisecrets.vaultname="$KVNAME",csisecrets.tenantId="$KVTENANT",csisecrets.clientId="$CSISECRET_CLIENTID",dnsname="$DNSNAME" --dry-run

