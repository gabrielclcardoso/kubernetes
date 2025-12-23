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

kubectl apply -k ../confs/argocd/
kubectl rollout status deployment/argocd-server -n argocd

kubectl apply -f ../confs/argocd/ingress.yaml

### argoCD Configuration###
echo "argoCD deployed, starting configuration"

DEFAULT_PASSWD=$(argocd admin initial-password -n argocd | head -1)
argocd login localhost --username admin --password "$DEFAULT_PASSWD" --insecure --grpc-web
argocd account update-password --account admin --current-password "$DEFAULT_PASSWD" --new-password "$NEW_PASSWD" --grpc-web
