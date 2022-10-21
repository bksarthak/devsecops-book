#!/bin/bash

PROFILE=<INPUT_YOUR_AWS_PROFILE>
REGION=<INPUT_YOUR_REGION>
PRODUCTID=$(aws servicecatalog describe-product --name eks-provision --region <INPUT_YOUR_REGION> --query ProductViewSummary.ProductId --output text)
PROVISIONARTIFACTID=$(aws servicecatalog describe-product --name eks-provision --region <INPUT_YOUR_REGION> --query ProvisioningArtifacts[*].Id --output text)

export parameters=(Key=VPCProductName,Value=EKSInfra
            Key=VPCProductVersion,Value=v1.1
            Key=IAMProductName,Value=EKSIAM
            Key=IAMProductVersion,Value=v1.0
            Key=EKSProductName,Value=EKSCluster
            Key=EKSProductVersion,Value=v1.1
            Key=EKSLOGProductName,Value=EKSLog
            Key=EKSLOGProductVersion,Value=v1.0
            Key=EKSNodeGroupProductName,Value=EKSNodegroup
            Key=EKSNodeGroupProductVersion,Value=v1.1
            Key=EKSLambdaProductName,Value=EKSLambda
            Key=EKSLambdaProductVersion,Value=v1.0
            Key=EKSEndPointsProductName,Value=EKSEndPoints
            Key=EKSEndPointsProductVersion,Value=v1.0
            Key=VpcCidr,Value=10.10.0.0/16
            Key=PrivateSubnetACidr,Value=10.10.4.0/24
            Key=PrivateSubnetBCidr,Value=10.10.5.0/24
            Key=PrivateSubnetCCidr,Value=10.10.6.0/24
            Key=PrivateSubnetDCidr,Value=10.10.7.0/24
            Key=PublicSubnetACidr,Value=10.10.8.0/24
            Key=PublicSubnetBCidr,Value=10.10.9.0/24
            Key=VolumeSize1,Value=60
            Key=VolumeSize2,Value=60
            Key=VolumeSize3,Value=60
            Key=InstanceType1,Value=m5.4xlarge
            Key=InstanceType2,Value=m5.4xlarge
            Key=InstanceType3,Value=m5.4xlarge
            Key=MinInstances1,Value=1
            Key=MinInstances2,Value=1
            Key=MinInstances3,Value=1
            Key=MaxInstances1,Value=3
            Key=MaxInstances2,Value=3
            Key=MaxInstances3,Value=3
            Key=DesiredInstances1,Value=1
            Key=DesiredInstances2,Value=1
            Key=DesiredInstances3,Value=1
            Key=CreatePublicSubnets,Value=true
            Key=CreatePrivateSubnets,Value=true
            Key=EksVersion,Value=1.23
            Key=EksName,Value=ekscluster
            Key=EksNodeGroupName1,Value=nodegroup1
            Key=EksNodeGroupName2,Value=nodegroup2
            Key=EksNodeGroupName3,Value=nodegroup3
            Key=S3BucketPath,Value=<s3_bucket_for_sc_products_lambda_function>
            Key=ZipFileName,Value=lambda.zip
            Key=PublicIP1,Value=173.36.0.0/14
            Key=PublicIP2,Value=72.163.0.0/16
            Key=PublicIP3,Value=128.107.0.0/16
            Key=PublicIP4,Value=144.254.0.0/16
            Key=PublicIP5,Value=52.24.252.26/32
            Key=EKSLogTypes,Value="\"api,audit,authenticator,controllerManager,scheduler\""
        )

aws servicecatalog provision-product \
    --provisioned-product-name eks-provision \
    --provisioning-artifact-id $PROVISIONARTIFACTID \
    --product-id $PRODUCTID \
    --provisioning-parameters "${parameters[@]}" \
    --profile $PROFILE \
    --region $REGION
