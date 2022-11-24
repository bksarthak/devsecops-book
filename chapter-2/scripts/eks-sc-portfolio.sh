#!/bin/bash

aws cloudformation create-stack --template-body file://$HOME/devsecops-book/chapter-2/template/ServiceCatalogProduct.yml  \
--stack-name EKSPortfolio --parameters file://$HOME/devsecops-book/chapter-2/parameter/ServiceCatalog.json --capabilities CAPABILITY_NAMED_IAM --region <INPUT_YOUR_REGION>