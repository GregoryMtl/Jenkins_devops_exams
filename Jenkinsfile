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

        // stage('Docker Clean') {
        //     steps {
        //         script{
        //             sh '''
        //             docker stop $(docker ps -aq);
        //             docker rm -f $(docker ps -aq);
        //             '''
        //         } 
        //     }
        // }

        // https://www.jenkins.io/blog/2017/09/25/declarative-1/
        // On nettoie les containers actifs, et on build séparément les deux images
        // Cela simplifiera l'organisation et la création des charts
        
        stage('Docker Build') { 
            parallel {
                stage('Build Image CAST') {
                    steps {
                        sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:latest ./cast-service'
                    }
                }

                stage('Build Image MOVIE') {
                    steps {
                        sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:latest ./movie-service'
                    }
                }
            }
        }

        stage('Docker Push') {

            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:latest
                    docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:latest
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
                    ls
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install jenkinsexam ./helm  --values=./helm/values.yaml --create-namespace --namespace dev
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
                    ls
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install jenkinsexam ./helm  --values=./helm/values.yaml --create-namespace --namespace qa
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
                    ls
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install jenkinsexam ./helm  --values=./helm/values.yaml --create-namespace --namespace staging
                    '''
                }
            }
        }

        stage('Deploiement en prod') {
            // On vérifie que nous sommes bien sur la branche master
            when {
                expression { env.GIT_BRANCH == 'origin/master' }
            }
            steps {

                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Validez-vous le déploiement en production ?', ok: 'Yes'
                }

                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
                    cat $KUBECONFIG > .kube/config
                    helm upgrade --install jenkinsexam ./helm  --values=./helm/values.yaml --create-namespace --namespace prod
                    '''
                }
            }
        }
    }
}