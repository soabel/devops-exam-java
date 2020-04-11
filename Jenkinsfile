@Library('jenkins-library@master') _

pipeline {
    agent any 
    environment {
        PROJECT_ID="devops-soabel"
        APP_NAME="myjavaapp"
        DOCKER_IMAGE_VERSION="0.0.1"
        DOCKER_IMAGE_TAG="gcr.io/${PROJECT_ID}/${APP_NAME}:${DOCKER_IMAGE_VERSION}"
        DOCKER_IMAGE_PORT=8080
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'whoami' 
                sh 'pwd'
                sh 'docker ps' 
                sh 'gcloud info' 
            }
            
        }
        stage('Pre build') {
            steps {
                mavenBuild(
                    image: "image test library"
                )
            }
        }
        // stage('Build') {
        //     agent {
        //         docker {
        //             reuseNode true
        //             image 'maven:3.6.3-jdk-8'
        //         }
        //     }
        //     steps {
        //         sh 'mvn clean install' 
        //     }
        // }
        stage('Build and Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    docker build -t ${APP_NAME} . && docker tag ${APP_NAME} ${DOCKER_IMAGE_TAG} && sudo docker push ${DOCKER_IMAGE_TAG}
                """
            }
        }

        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    cp deploy/kubernetes/deployment.yml deploy/kubernetes/deployment-out.yml 
                    cp deploy/kubernetes/service.yml deploy/kubernetes/service-out.yml 
                    cp deploy/kubernetes/ingress.yml deploy/kubernetes/ingress-out.yml 

                    sed -i -e "s/<APP_NAME>/${APP_NAME}/g" deploy/kubernetes/deployment-out.yml 
                    sed -i -e "s+<DOCKER_IMAGE_TAG>+${DOCKER_IMAGE_TAG}+g" deploy/kubernetes/deployment-out.yml
                    sed -i -e "s/<DOCKER_IMAGE_PORT>/${DOCKER_IMAGE_PORT}/g" deploy/kubernetes/deployment-out.yml 

                    sed -i -e "s/<APP_NAME>/${APP_NAME}/g" deploy/kubernetes/service-out.yml 
                    sed -i -e "s/<APP_NAME>/${APP_NAME}/g" deploy/kubernetes/ingress-out.yml 

                    kubectl apply -f deploy/kubernetes/deployment-out.yml && \
                    kubectl apply -f deploy/kubernetes/service-out.yml && \
                    kubectl apply -f deploy/kubernetes/ingress-out.yml
                """
            }
        }
    }
}