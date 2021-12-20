#helm install externaldns ./externaldns --dry-run --debug --set externaldns.domainfilter="test"

helm install azure-vote ./azurevote-simple -n az --create-namespace
kubectl get po -n az
kubectl get svc -n az
