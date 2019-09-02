cloud = "GCP"
dockerRepo = "ci-cd-demo"

if (cloud == "GCP"){
    registry = 'gcr.io'
    registryCreds = 'gcr:gke-test-251020'
    kubernetes = 'https://35.226.214.183'
    kubernetesCreds = 'GKE'

} else {
    registry = '174863393238.dkr.ecr.us-west-2.amazonaws.com'
    registryCreds = 'ecr:us-west-2:AWS_CREDS'
    kubernetes = 'https://74A99A33DEC6AE680D631929F926AFAE.sk1.us-west-2.eks.amazonaws.com'
    kubernetesCreds = 'EKS'
}

pipeline {
    options {
      skipDefaultCheckout()
    }
    agent {
        kubernetes {
        cloud 'kubernetes-gcp'
        yaml """
        spec:
          containers:
            - name: docker
              image: docker:18.05-dind
              securityContext:
                privileged: true
            - name: kubectl
              image: lachlanevenson/k8s-kubectl:v1.8.8
              command:
              - cat
              tty: true
        """
        }
    }
    stages {
        stage('Build Image & Run Tests') {
            steps {
                container('docker') {
                    checkout scm
                    sh "docker build -t  ${registry}/${dockerRepo}:${env.BUILD_ID} ."
                }
            }
        }
        stage('Push to Registry') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry("https://${registry}", registryCreds) {
                            sh "docker push ${registry}/${dockerRepo}:${env.BUILD_ID}"
                        }   
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('kubectl') {
                    withKubeConfig([credentialsId: kubernetesCreds, serverUrl: kubernetesCluster]) {
                      sh "ECR_REPO=${dockerRepo} TAG=${env.BUILD_ID} kubectl apply -f ./BaseWithAdmin/kubernetes/net-app.yaml"
                   }
                }
            }
        }
    }
}
