# README

Please follow these instructions to deploy the stacks successfully. There are some parameters which need to be edited before the stack is launched.

> **Note: The instructions assume the IAM principal you are using contains all the permissions you need to perform these steps.**

## Instructions for stack name `EKSPortfolio`

In `ServiceCatalogPortfolio.yml`, `ArtifactLoadTemplateFromUrl` parameter has a default value of `https://s3.amazonaws.com/` which is not a valid S3 object path. If you look at the parameters within `ServiceCatalog.json` file (which is the parameter file being fed into the Cloudformation template), you will notice the parameter being passed to this is of value `"https://s3.amazonaws.com/eksportfolioproducts/eks_provision.yml"`. So, this means the template is looking for this `eks_provision.yml` file in a bucket named `eksportfolioproducts`.

- **Step 1**: Create a bucket with name of your choice . For demonstration purposes, we will use the name `tetralogy` as the bucket name.

```
aws s3 mb s3://tetralogy
```

A successful output will look like this:

```
make_bucket: tetralogy
```

> Note: Make sure your bucket has public access turned on by default to prevent public access from unauthorized entities. More information here : https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html?icmpid=docs_s3_hp_block_public_access_page

- **Step 2**: Upload the `eks_provision.yml` file from under `devsecops-book/chapter-2/template/eks_provision.yml` path to your newly created bucket.

- **Step 3**: Update the parameter `ArtifactLoadTemplateFromUrl` to the path of your uploaded file from Step 2 within the `ServiceCatalog.json` file.

> Note: Make sure you use the S3 Object URL which starts with `https://`

- **Step 4** : Run the create-stack commenat for the `EKSPortfolio` stack name as instructed in the book.

## Instructions for copying service catalog products into S3 bucket

While doing the `aws s3 cp` command for copying the AWS Service Catalog files, make sure you have a bucket already created. Use that bucket name to replace in the command.

For example, if your bucket name is `test-123`, the command should look something like below --

> Note: the folder name is `product/` not `service_catalog_products` as per the book.

```
aws s3 cp product/ \
s3://humpty-dump/ \
--recursive \
--exclude "*" \
--include "*.yml" \
--include "*.zip" \
--region us-east-1
```

## Instructions for creating stack for the networking product (stack name `EKSNetwork`)

- **Step 1**: After the files from the `product/` folder are uploaded, copy the `https:` URL of the `network.yml` file into the `ArtifactLoadTemplateFromUrl` value within the `NetworkProduct.json` file within the `parameter` folder.
- **Step 3**: Launch the `EKSNetwork` stack

## Instructions for creating `EKSIAM` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/IAMProduct.json` file with the value of `iam.yml` file from the bucket you copied the `product/` folder into.

## Instructions for creating `EKSCluster` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/EKSProduct.json` file with the value of `eks_cluster.yml` file from the bucket you copied the `product/` folder into.

## Instructions for creating `EKSNodeGroup` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/EKSNodeGroupProduct.json` file with the value of `eks_nodegroup.yml` file from the bucket you copied the `product/` folder into.

> **ERRATA** : The `--template-body` parameter in your create-stack command should be `template/ServiceCatalogProduct.yml` instead of `eks_nodegroup.yml` as stated in the book

## Instructions for creating `EKSLambda` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/EKSLambdaProduct.json` file with the value of `eks_lambda_vpc.yml` file from the bucket you copied the `product/` folder into.

## Instructions for creating `EKSVPCEndpoint` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/VPCEndpointProduct.json` file with the value of `vpc_endpoints.yml` file from the bucket you copied the `product/` folder into.

## Instructions for creating `EKSLog` stack

Similar to the `EKSNetwork` stack, update the S3 URL within the `parameter/EKSLoggingProduct.json` file with the value of `eks_control_plane_logging.yml` file from the bucket you copied the `product/` folder into.

## What are the scripts within `/scripts` folder?

The scripts within the folder are to speed up the deployment through a single bash script, but they are not necessary per se. The order of launch for these scripts is as below:

First, run `eks-sc-portfolio.sh` to deploy the portfolio.
Second, run `eks-sc-products.sh` to deploy all the products.

> Note: You would still need to update all the parameters within the `/parameter` folder to make sure the script reads the right path to the objects referred in the parameter.

## How to run `/scripts/eks-provision.sh`?

> **Note**: Make sure all the products and portfolio above have been launched before you get to this step. We assume that your IAM principal used for this step has permissions to interact with AWS Service Catalog.


Give this script executable permission through the `chmod` command before execution.

Confirm that your AWS Service Catalog Portfolio has access to the IAM identity you are using to launch the product. In order to confirm this, you can visit "Access" tab for your portfolio in the AWS Service Catalog UI or you can run this command to get the associated principals `aws servicecatalog list-principals-for-portfolio --portfolio-id <your-portfolio-id>`

If your desired IAM principal is missing in the output of the command, you can associate it with the following command:
```
aws servicecatalog associate-principal-with-portfolio \
--portfolio-id <YOUR_PORTFOLIO_ID> \
--principal-arn <YOUR_DESIRED_ARN> \
--principal-type IAM
```

To confirm everything went smoothly you can run `aws servicecatalog list-portfolios` and see the portfolio added(as the IAM principal you used in above command).

Provide the AWS Profile that you launched the infrastructure into, you can use the `aws configure list-profiles` command to get the list of available profiles.

Update the value you want to use within `scripts/eks-provision.sh`, this includes the following things:
1. AWS Profile
2. AWS region you want to deploy to
3. Update the AWS region (for example `us-east-1`) within lines starting with `PRODUCTID` and `PROVISIONARTIFACTID` 
4. Update the bucket path for the variable named `S3BucketPath` in `parameter/eks-provisioner.json`

> **Debugging note 1**: Make sure your product name (in line 5 and 6) within `eks-provision.sh` file is same as the product which contains description value of `eks-provisioner`.

> **Debugging note 2**: If you have changed your product names while launching the stacks above, make sure the product names match to the parameters passed within `parameter/eks-provisioner.json` file.

> **Debugging note 3**: Make sure the product versions match with the variables in the `parameter/eks-provisioner.json` file. Entirely depends on how many updates you have done to product.

After you have updated all of the above, run the script in your terminal.
