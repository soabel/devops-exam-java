#!/bin/bash
#Script  de deploy service

## VARIABLE DEFINITIONS

CLUSTER_NAME="exam-cluster-task2"
CLUSTER_DESCRIPTION="Test Cluster"
PROJECT_ID="devops-soabel"
REGION="us-central1"
NODE_COUNT=1
MACHINE_TYPE="n1-standard-1"


## REPLACE VARIABLRS

cp deploy/terraform/variables.tf.txt deploy/terraform/variables-out.tf
sed -i -e "s/{CLUSTER_NAME}/$CLUSTER_NAME/g" deploy/terraform/variables-out.tf
sed -i -e "s/{CLUSTER_DESCRIPTION}/$CLUSTER_DESCRIPTION/g" deploy/terraform/variables-out.tf
sed -i -e "s/{PROJECT_ID}/$PROJECT_ID/g" deploy/terraform/variables-out.tf
sed -i -e "s/{REGION}/$REGION/g" deploy/terraform/variables-out.tf
sed -i -e "s/{NODE_COUNT}/$NODE_COUNT/g" deploy/terraform/variables-out.tf
sed -i -e "s/{MACHINE_TYPE}/$MACHINE_TYPE/g" deploy/terraform/variables-out.tf


echo --Initialize Terraform: cd deploy/terraform/ && terraform init 

cd deploy/terraform/ && terraform init 

echo --Create  Kubernetes Cluster

terraform plan

cd -

pwd

# echo --Configure connection to CLuster with kubectl

# gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID

# echo --Configure Google Registry

# kubectl create secret docker-registry gcr-json-key \
# --docker-server=eu.gcr.io \
# --docker-username=_json_key \
# --docker-password="$(cat deploy/terraform/credentials.json)" \
# --docker-email=socrateslaiza@gmail.com

# kubectl patch serviceaccount default \
# -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'

# echo --Compile Maven

# mvn clean package

# echo --Build and push Docker image

# docker build -t myjavaapp . && docker tag myjavaapp gcr.io/exam-devops/myjavaapp:0.0.1 && docker push gcr.io/exam-devops/myjavaapp:0.0.1

# echo --Deploy to Kubernetes Cluster

# kubectl apply -f deploy/kubernetes/deployment.yml && kubectl apply -f deploy/kubernetes/service.yml && kubectl apply -f deploy/kubernetes/ingress.yml