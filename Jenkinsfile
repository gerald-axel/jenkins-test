pipeline {
  agent {
    kubernetes {
      label 'kubernetes'
      cloud 'kubernetes'
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
