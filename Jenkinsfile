ecrRegistry = "174863393238.dkr.ecr.us-west-2.amazonaws.com"
eksCluster = "https://74A99A33DEC6AE680D631929F926AFAE.sk1.us-west-2.eks.amazonaws.com"

pipeline {
	agent any
    stages {
        stage('Build & Run Unit test') {
            steps {
            	script {
            		checkout scm 
	                sh "docker build -t ${ecrRegistry}/ci-cd-demo:${env.BUILD_ID} ." 
                }
            }
        }
        stage('Push to Registry') {
	      steps {
	      		script {
			        withDockerRegistry([ credentialsId: "ECR", url: ecrRegistry ]) {
			          sh "docker push ${ecrRegistry}/ci-cd-demo:${env.BUILD_ID}"
			        }
	      		}
	        }
    	}
        stage('Deploy') {
            steps {
            	script {
	                withKubeConfig([credentialsId: 'EKS', serverUrl: eksCluster]) {
                      sh "kubectl run test --image=${eksCluster}/ci-cd-demo:${env.BUILD_ID} --replicas=1"
	                }
                 }
            }
        }
    }
}
