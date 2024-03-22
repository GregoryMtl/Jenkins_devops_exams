pipeline {
    environment
    {
        DOCKER_ID = "gregoryp"
        DOCKER_PASS = credentials("DOCKER_HUB_PASS")

        DOCKER_IMAGE_CAST  = "jenkins-cast"
        DOCKER_IMAGE_MOVIE = "jenkins-movie"

        DOCKER_TAG = "v.${BUILD_ID}.0" 

        KUBECONFIG = credentials("config")
    }
    agent any
    stages {

        // https://www.jenkins.io/blog/2017/09/25/declarative-1/
        // On nettoie les containers actifs, et on build séparément les deux images
        // Cela simplifiera l'organisation et la création des charts
        stage(' Docker Build') { 

            stage('Cleaning up') {
                sh '''
                docker stop $(docker ps -aq)
                docker rm -f $(docker ps -aq)
                '''
            }

            parallel {
                stage('Build Image CAST') {
                    sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG ./services/cast'
                }

                stage('Build Image MOVIE') {
                    sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG ./services/movie'
                }
            }
        }

        stage('Docker Push') {

            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                    docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploiement en dev') {
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install cast-service ./cast-service --namespace dev
                    helm upgrade --install movie-service ./movie-service --namespace dev
                    '''
                }
            }
        }
        
        stage('Deploiement en QA') {
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install cast-service ./cast-service --namespace qa
                    helm upgrade --install movie-service ./movie-service --namespace qa
                    '''
                }
            }
        }

        stage('Deploiement en staging') {
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install cast-service ./cast-service --namespace staging
                    helm upgrade --install movie-service ./movie-service --namespace staging
                    '''
                }
            }
        }

        stage('Deploiement en prod') {
            // On vérifie que nous sommes bien sur la branche master
            when {
                branch 'master'
            }
            steps {

                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Validez-vous le déploiement en production ?', ok: 'Yes'
                }

                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install cast-service ./cast-service --namespace prod
                    helm upgrade --install movie-service ./movie-service --namespace prod
                    '''
                }
            }
        }
}