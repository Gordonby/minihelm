#helm install externaldns ./externaldns --dry-run --debug --set externaldns.domainfilter="test"

helm install externaldns ./externaldns --set externaldns.domainfilter="test"
kubectl get deployment externaldns