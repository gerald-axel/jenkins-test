ecrRegistry = "https://174863393238.dkr.ecr.us-west-2.amazonaws.com"
ecrRepo = "174863393238.dkr.ecr.us-west-2.amazonaws.com/ci-cd-demo"
eksCluster = "https://74A99A33DEC6AE680D631929F926AFAE.sk1.us-west-2.eks.amazonaws.com"

pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    checkout scm 
                    sh "docker build -t ${ecrRepo}:${env.BUILD_ID} ." 
                }
            }
        }
        stage('Run Unit test') {
            steps {
                script {
                    checkout scm 
                    sh "docker run ${ecrRepo}:${env.BUILD_ID} mvn surefire:test" 
                }
            }
        }
        stage('Push to Registry') {
	      steps {
	      		script {
			        withDockerRegistry([ credentialsId: "ECR", url: ecrRegistry ]) {
			          sh "docker push ${ecrRepo}:${env.BUILD_ID}"
			        }
	      		}
	        }
    	}
        stage('Deploy') {
            steps {
            	script {
	                withKubeConfig([credentialsId: 'EKS', serverUrl: eksCluster]) {
                      sh "kubectl run test-${env.BUILD_ID} --image=${ecrRepo}:${env.BUILD_ID} --replicas=1"
	                }
                 }
            }
        }
    }
}
