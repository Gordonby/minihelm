#helm install externaldns ./externaldns --dry-run --debug --set externaldns.domainfilter="test"

kubectl create ns az
helm install azure-vote ./azurevote-simple -n az
kubectl get po -n az
kubectl get svc -n az
