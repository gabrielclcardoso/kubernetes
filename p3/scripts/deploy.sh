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
sleep 0.5
echo "argoCD deployed"

### argoCD Configuration###
echo "Starting argoCD configuration"

echo "Loggin in with the default passord..."
DEFAULT_PASSWD=$(argocd admin initial-password -n argocd | head -1)
argocd login argocd.localhost --username admin --password "$DEFAULT_PASSWD" --insecure --grpc-web

echo "Changing the default password"
argocd account update-password --account admin --current-password "$DEFAULT_PASSWD" --new-password "$NEW_PASSWD" --grpc-web

echo "Configuring deployed application"
kubectl create namespace dev
kubectl config set-context --current --namespace=argocd
argocd app create will-playground --repo https://github.com/gabrielclcardoso/gcorreia_argocd_application --path . --dest-server https://kubernetes.default.svc --dest-namespace dev
argocd app sync will-playground 
argocd app set will-playground --sync-policy automated
