ecrRegistry = "https://174863393238.dkr.ecr.us-west-2.amazonaws.com"
ecrRepo = "174863393238.dkr.ecr.us-west-2.amazonaws.com/ci-cd-demo"
eksCluster = "https://74A99A33DEC6AE680D631929F926AFAE.sk1.us-west-2.eks.amazonaws.com"

pipeline {
    options {
      skipDefaultCheckout()
      clearWorkspace()
    }
    agent {
        kubernetes {
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
                    sh "docker build -t ${ecrRepo}:${env.BUILD_ID} ."
                }
            }
        }
        stage('Push to Registry') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry(ecrRegistry, 'ecr:us-west-2:AWS_CREDS') {
                            sh "docker push ${ecrRepo}:${env.BUILD_ID}"
                        }   
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('kubectl') {
                    withKubeConfig([credentialsId: 'EKS', serverUrl: eksCluster]) {
                      sh "ECR_REPO=${ecrRepo} TAG=${env.BUILD_ID} kubectl apply -f ./BaseWithAdmin/kubernetes/net-app.yaml"
                   }
                }
            }
        }
    }
}
