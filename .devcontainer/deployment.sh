#!/bin/bash

kind create cluster --config .devcontainer/kind-cluster.yaml --wait 300s

# install the Dynatrace operator
helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator
kubectl create secret generic datadog-secret --from-literal api-key=$DD_TOKEN
kubectl apply -f .devcontainer/datadog-agent.yaml

# deploy microservices without loadgenerator service
# Note in kustomize/kustomization.yaml the components/remove-loadgen is enabled
kubectl apply -k kustomize/.

# wait for pods to be ready before port forwarding
kubectl rollout status deployment frontend

# forward all traffic to 8080 on the local machine
nohup kubectl port-forward deployment/frontend 8080:8080 &
