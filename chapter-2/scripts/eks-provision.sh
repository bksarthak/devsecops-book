#!/bin/bash

PROFILE=default
REGION=us-east-1
PRODUCTID=$(aws servicecatalog describe-product --name DEV-eks-provisioner-product-us-east-1 --region us-east-1 --query ProductViewSummary.ProductId --output text)
PROVISIONARTIFACTID=$(aws servicecatalog describe-product --name DEV-eks-provisioner-product-us-east-1 --region us-east-1 --query 'ProvisioningArtifacts[0].Id' --output text)


aws servicecatalog provision-product \
    --provisioned-product-name "eks-provision" \
    --provisioning-artifact-id $PROVISIONARTIFACTID \
    --product-id $PRODUCTID \
    --provisioning-parameters file://parameter/eks-provisioner.json \
    --profile $PROFILE \
    --region $REGION
