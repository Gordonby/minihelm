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

1. ExternalDNS - as used by https://github.com/Azure/Aks-Construction
1. Azure Vote - the classic AKS voting app.
