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
            }
        }
        stage('Build') {
            agent {
                docker {
                    reuseNode true
                    image 'maven:3.6.3-jdk-8'
                }
            }
            steps {
                sh 'mvn clean install' 
            }
        }
        stage('Build and Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    docker build -t ${APP_NAME} . && docker tag ${APP_NAME} ${DOCKER_IMAGE_TAG} && docker push ${DOCKER_IMAGE_TAG}
                """
            }
        }

        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    kubectl apply -f deploy/kubernetes/deployment-out.yml \
                    kubectl apply -f deploy/kubernetes/service-out.yml \
                    kubectl apply -f deploy/kubernetes/ingress-out.yml
                """
            }
        }
    }
}