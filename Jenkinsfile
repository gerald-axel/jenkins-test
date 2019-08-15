pipeline {
  agent {
    kubernetes {
      label 'kubernetes'
      cloud 'cicd-eks-demo'
    }
  }
  stages {
    stage('test') {
      steps {
        container('kubectl') {
          sh "kubectl version"
        }
      }
    }
  }
}
