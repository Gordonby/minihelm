$setparams='ingress.enabled=true, ingress.appGwPrivateIp="true", front.service.azureLbInternal=true, front.service.type="ClusterIP"'

echo $setparams

helm upgrade --install azure-vote ./azurevote --set $setparams -n default --dry-run
kubectl get po 
kubectl get svc
