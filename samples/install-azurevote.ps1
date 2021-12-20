setparams='ingress.enabled=true,ingress.appGwPrivateIp="false",front.service.azureLbInternal=true,front.service.type="ClusterIP"'

echo $setparams

helm upgrade --install azurevotey ./azurevote --set $setparams -n default --dry-run

helm upgrade --install azurevotey ./azurevote --set $setparams -n default

kubectl get po
kubectl get svc
