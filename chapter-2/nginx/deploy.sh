
#!/bin/bash

echo "Conecting to $1 Cluster in $2"

aws eks update-kubeconfig --region $2 --name $1

echo "Deploying sample application"
kubectl apply -f eks-sample-deployment.yaml
kubectl apply -f eks-sample-service.yaml

echo "Deployed application"
kubectl get all -n eks-sample-app
