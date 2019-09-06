deploymentCloud = "kubernetes-gcp"

if (deploymentCloud == "kubernetes-gcp"){
    registry = 'https://gcr.io'
    registryCreds = 'gcr:gke-test-251020'
    kubernetes = 'https://35.239.124.189'
    kubernetesCreds = 'geraldaxelalbamo'
    dockerRepo = "gcr.io/gke-test-251020/ci-cd-demo"
} else {
    /* kubernetes-aws */
    registry = 'https://174863393238.dkr.ecr.us-west-2.amazonaws.com'
    registryCreds = 'ecr:us-west-2:AWS_CREDS'
    kubernetes = 'https://74A99A33DEC6AE680D631929F926AFAE.sk1.us-west-2.eks.amazonaws.com'
    kubernetesCreds = 'EKS'
    dockerRepo = "174863393238.dkr.ecr.us-west-2.amazonaws.com/ci-cd-demo"
}

pipeline {
    options {
      skipDefaultCheckout()
    }
    agent {
        kubernetes {
        cloud deploymentCloud
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
            - name: helm
              image: dtzar/helm-kubectl
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
                    sh "docker build -t  ${dockerRepo}:${env.BUILD_ID} ."
                }
            }
        }
        stage('Push to Registry') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry(registry, registryCreds) {
                            sh "docker push ${dockerRepo}:${env.BUILD_ID}"
                        }   
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('helm') {
                    withKubeConfig([credentialsId: kubernetesCreds, serverUrl: kubernetes]) {
                      sh """
                        helm install --set Tag=${env.BUILD_ID} -f unit-test.yaml .
                      """
                   }
                }
            }
        }
    }
}
