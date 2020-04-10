#!/bin/bash
#Script  de deploy service

echo --Initialize Terraform: cd deploy/terraform/ && terraform init 

cd deploy/terraform/ && terraform init 

echo --Create  Kubernetes Cluster

terraform apply

cd -

echo --Configure Google Registry

pwdkubectl create secret docker-registry gcr-json-key \
--docker-server=eu.gcr.io \
--docker-username=_json_key \
--docker-password="$(cat deploy/terraform/credentials.json)" \
--docker-email=alfredo.benaute@gmail.com

kubectl patch serviceaccount default \
-p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'

echo --Compile Maven

mvn clean package

echo --Build and push Docker image

docker build -t myjavaapp . && docker tag myjavaapp gcr.io/exam-devops/myjavaapp:0.0.1 && docker push gcr.io/exam-devops/myjavaapp:0.0.1

echo --Deploy to Kubernetes Cluster

kubectl apply -f deploy/kubernetes/deployment.yml && kubectl apply -f deploy/kubernetes/service.yml && kubectl apply -f deploy/cabernets/ingress.yml