#!/bin/bash
#Script  de deploy service

## ARGUMENTS

if [ -z $1 ] ; then
  echo "First parameter needed. CREATE | DESTROY" && exit 1;
fi
if [[ "$1" != "CREATE" && "$1" != "DESTROY" ]]; then
  echo "The value of first argument is invalid!. The values are CREATE | DESTROY" && exit 1;
fi
if [ -z $2 ] ; then
  echo "Second parameter needed!" && exit 1;
fi

if [[ "$1" != "" ]]; then
    OPERATION="$1"
fi

if [[ "$2" != "" ]]; then
    OUTPUT=$(pwd)/"$2"
    touch $OUTPUT
    echo "LOG output" | tee  $OUTPUT
    echo "==========" | tee -a $OUTPUT
fi

## VARIABLE DEFINITIONS
APP_NAME="myjavaapp"
CREDENTIALS_FILE="~/credentials.json"
CLUSTER_NAME="exam-cluster-task2"
CLUSTER_DESCRIPTION="Test Cluster task 2"
PROJECT_ID="devops-soabel"
REGION="us-central1"
NODE_COUNT=1
MACHINE_TYPE="n1-standard-1"
ACCOUNT_EMAIL=socrateslaiza@gmail.com
DOCKER_IMAGE_VERSION=0.0.1
DOCKER_IMAGE_TAG="gcr.io/$PROJECT_ID/$APP_NAME:$DOCKER_IMAGE_VERSION"
DOCKER_IMAGE_PORT=8080
JENKINS_SERVER_NAME="jenkins-master"

## REPLACE VARIABLES
echo --1: REPLACE VARIABLES | tee -a $OUTPUT
cp deploy/terraform/variables.tf.txt deploy/terraform/variables-out.tf

#-- Terraform Variables
sed -i -e "s+{CREDENTIALS_FILE}+$CREDENTIALS_FILE+g" deploy/terraform/variables-out.tf
sed -i -e "s/{CLUSTER_NAME}/$CLUSTER_NAME/g" deploy/terraform/variables-out.tf
sed -i -e "s/{CLUSTER_DESCRIPTION}/$CLUSTER_DESCRIPTION/g" deploy/terraform/variables-out.tf
sed -i -e "s/{PROJECT_ID}/$PROJECT_ID/g" deploy/terraform/variables-out.tf
sed -i -e "s/{REGION}/$REGION/g" deploy/terraform/variables-out.tf
sed -i -e "s/{NODE_COUNT}/$NODE_COUNT/g" deploy/terraform/variables-out.tf
sed -i -e "s/{MACHINE_TYPE}/$MACHINE_TYPE/g" deploy/terraform/variables-out.tf
sed -i -e "s/{JENKINS_SERVER_NAME}/$JENKINS_SERVER_NAME/g" deploy/terraform/variables-out.tf

#-- Kubernetes Files
cp deploy/kubernetes/deployment.yml deploy/kubernetes/deployment-out.yml 
cp deploy/kubernetes/service.yml deploy/kubernetes/service-out.yml 
cp deploy/kubernetes/ingress.yml deploy/kubernetes/ingress-out.yml 

sed -i -e "s/<APP_NAME>/$APP_NAME/g" deploy/kubernetes/deployment-out.yml 
sed -i -e "s+<DOCKER_IMAGE_TAG>+$DOCKER_IMAGE_TAG+g" deploy/kubernetes/deployment-out.yml
sed -i -e "s/<DOCKER_IMAGE_PORT>/$DOCKER_IMAGE_PORT/g" deploy/kubernetes/deployment-out.yml 

sed -i -e "s/<APP_NAME>/$APP_NAME/g" deploy/kubernetes/service-out.yml 
sed -i -e "s/<APP_NAME>/$APP_NAME/g" deploy/kubernetes/ingress-out.yml 

# exit -1 # TODO: borrar

echo --2: INITIALIZE TERRAFORM | tee -a $OUTPUT

cd deploy/terraform/ && terraform init | tee -a $OUTPUT

if [[ "$OPERATION" == "DESTROY" ]]; then
    cd -
    if [[ !($(gcloud container clusters list | grep -c $CLUSTER_NAME) -ge 0) ]]; then
        echo --The Cluster: $CLUSTER_NAME not exists | tee -a $OUTPUT
        exit 0
    fi

    echo --3: CONNECT TO Kubernetes Cluster $CLUSTER_NAME | tee -a $OUTPUT

    gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID >> $OUTPUT

    echo --4: DELETE DEPLOYMENT, SERVICES AND INGRESS | tee -a $OUTPUT

    # DELETE DEPLOYMENT, SERVICE AND INGRESS

    EXISTS_SVC=`kubectl get svc | grep -e $APP_NAME`
    EXISTS_DEPLOY=`kubectl get deploy | grep -e $APP_NAME`
    EXISTS_ING=`kubectl get ing | grep -e $APP_NAME`

    if [[ $EXISTS_SVC ]]; then
        kubectl delete -f deploy/kubernetes/deployment-out.yml | tee -a $OUTPUT
    else
        echo --Application not exists in cluster | tee -a $OUTPUT
    fi
    if [[ $EXISTS_DEPLOY ]]; then
        kubectl delete -f deploy/kubernetes/service-out.yml | tee -a $OUTPUT
    fi
    if [[ $EXISTS_ING ]]; then
        kubectl delete -f deploy/kubernetes/ingress-out.yml | tee -a $OUTPUT
    fi
    
    echo --5: DELETE KUBERNETES CLUSTER: $CLUSTER_NAME
    #DELETE CLUSTER
    cd deploy/terraform/ && terraform init | tee -a $OUTPUT

    pwd
    
    terraform destroy | tee -a $OUTPUT

    echo --The Cluster: $CLUSTER_NAME was deleted | tee -a $OUTPUT

    exit 0
fi
echo -e | tee -a $OUTPUT
echo --3: CREATE KUBERNETES CLUSTER: $CLUSTER_NAME | tee -a $OUTPUT

terraform apply | tee -a $OUTPUT
echo --The Cluster: $CLUSTER_NAME was created | tee -a $OUTPUT

if [[ !($(gcloud container clusters list | grep -c $CLUSTER_NAME) -ge 0) ]]; then
    echo --The Cluster: $CLUSTER_NAME not exists | tee -a $OUTPUT
    exit 0
fi

echo Kubernetes Cluster created: $CLUSTER_NAME | tee -a $OUTPUT

cd -

echo --4: CONNECT TO Kubernetes Cluster: $CLUSTER_NAME | tee -a $OUTPUT

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID | tee -a $OUTPUT

echo --5: CREATE SECRET TO REGISTRY | tee -a $OUTPUT

if [[ !($(kubectl get secret | grep -c gcr-json-key) -ge 0) ]]; then
    kubectl create secret docker-registry gcr-json-key \
    --docker-server=eu.gcr.io \
    --docker-username=_json_key \
    --docker-password="$(echo cat ${CREDENTIALS_FILE/\~/$HOME})" \
    --docker-email=$ACCOUNT_EMAIL

    if [[ !($(kubectl get secret | grep -c gcr-json-key) -ge 0) ]]; then
        echo --ERROR The secret not was created | tee -a $OUTPUT
        exit 0
    fi
    
    echo Kubernetes Secret created: $CLUSTER_NAME | tee -a $OUTPUT

fi

kubectl patch serviceaccount default \
-p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}' | tee -a $OUTPUT

echo --6: COMPILE AND PACKAGE - maven

mvn clean package

echo --7: BUILD EN PUSH IMAGE TO REGISTRY | tee -a $OUTPUT

docker build -t $APP_NAME . && docker tag $APP_NAME $DOCKER_IMAGE_TAG && docker push $DOCKER_IMAGE_TAG | tee -a $OUTPUT

echo --8: DEPLOY TO KUBERNETES CLUSTER

kubectl apply -f deploy/kubernetes/deployment-out.yml | tee -a $OUTPUT && \
kubectl apply -f deploy/kubernetes/service-out.yml | tee -a $OUTPUT && \
kubectl apply -f deploy/kubernetes/ingress-out.yml | tee -a $OUTPUT

echo --SUCCESSFULL DEPLOY !! | tee -a $OUTPUT

exit 0