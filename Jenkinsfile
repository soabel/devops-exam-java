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
                sh 'gcloud info' 
            }
            
        }
        stage('Build') {
            steps {
                // call to shared library
                mavenBuild(
                    image: "image test"
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
                    docker build -t ${APP_NAME} . && docker tag ${APP_NAME} ${DOCKER_IMAGE_TAG}
                """
            }
        }

    }
}