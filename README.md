# Mini Helm

Cut down Helm scaffold.

## Guide

Until i write a binary to do some of this.. Follow the following process
1. Copy the mini-helm directory, changing the name to that of your app
1. In Chart.yaml, change the name and description
1. In Values.yaml change properties to align with your existing manifest
1. In the Chart.yaml change the appVersion to represent your image tag
1. Start work in the templates directory, inserting snippets from your existing manifest. Don't yet worry about adding anything extra to values.yaml
1. Test that your helm chart deploys
1. Think about refactoring true "variables" into the values.yaml

## Samples

A few different packaged helm charts that i've done.

App | Chart Name | Description | Helm features / Notes
--- | ---------- | ----------- | ---------------------
ExternalDNS | ExternalDNS | As used by https://github.com/Azure/Aks-Construction | `service account` `cluster role` `cluster role binding`
Azure Voting App | AzureVote-Simple | The classic AKS voting app. | `sub charts` `networking policies` `load balancer` `no ingress`
Azure Voting App | AzureVote | The classic AKS voting app, with extended options for different configurations. | `sub charts` `networking policies` `load balancer` `conditional ingress`
CertManager ClusterIssuer | Certmanager | A Cert Manager ClusterIssuer config | `cluster issuer`
Javatlsapp | Javatlsapp | A simple java application that requires TLS communication | `csi` `keyvault` `agic`
