pipeline {
    agent any
    options {
        datadog(collectLogs: true, 
                tags: ["foo:bar", "bar:baz"],
                testVisibility: [ 
                    enabled: true, 
                    serviceName: "jenkins-wow", // the name of service or library being tested
                    languages: ["JAVA"], // languages that should be instrumented (available options are "JAVA", "JAVASCRIPT", "PYTHON", "DOTNET")
                    additionalVariables: ["my-var": "value"]  // additional tracer configuration settings (optional)
                ])
    }
    stages {
        stage('Example') {
            steps {
                echo "Hello world."
            }
        }
    }
}
