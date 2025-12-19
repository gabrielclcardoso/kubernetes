#!/bin/bash

### Bring up cluster ###

CLUSTER_NAME="p3-cluster"

if k3d cluster list "$CLUSTER_NAME" > /dev/null 2>&1; then

    echo "Cluster '$CLUSTER_NAME' found!"
    echo "Starting cluster..."
    
    k3d cluster start "$CLUSTER_NAME"
    
    echo "...Cluster started."

else

    echo "Cluster '$CLUSTER_NAME' not found."
    echo "Creating cluster..."
    
    k3d cluster create "$CLUSTER_NAME" --config ../confs/k3d/config.yaml
    
    echo "...Cluster created and started."

fi

### Start argoCD ###
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#kubectl port-forward svc/argocd-server -n argocd 8080:443
