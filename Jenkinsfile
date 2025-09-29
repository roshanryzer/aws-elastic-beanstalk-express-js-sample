pipeline {
    agent {
        docker {
            image 'node:16'
            args '-u root:root'
        }
    }
    
    options {
        // Build retention policy
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30', artifactNumToKeepStr: '5', artifactDaysToKeepStr: '7'))
        
        // Timeout for the entire pipeline
        timeout(time: 30, unit: 'MINUTES')
        
        // Timestamp logs
        timestamps()
        
        // Annotate console output
        ansiColor('xterm')
    }
    
    environment {
        BUILD_LOG_LEVEL = 'INFO'
        PIPELINE_LOG_LEVEL = 'DEBUG'
        DOCKER_IMAGE_NAME = "myapp"
        DOCKER_REGISTRY = "your-registry.com" // Update with your registry
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Starting checkout process..."
                checkout scm
                echo "Checkout completed successfully"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo "Installing Node.js dependencies..."
                sh 'npm install --save'
                echo "Dependencies installed successfully"
            }
        }
        
        stage('Run Tests') {
            steps {
                echo "Running unit tests..."
                sh 'npm test'
                echo "Tests completed successfully"
            }
        }
        
        stage('Security Scan') {
            steps {
                echo "Starting security vulnerability scan..."
                sh 'npm install -g snyk'
                sh 'snyk test --severity-threshold=high --json > snyk-results.json || true'
                echo "Security scan completed"
            }
            post {
                always {
                    // Archive security scan results
                    archiveArtifacts artifacts: 'snyk-results.json', fingerprint: true, allowEmptyArchive: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                echo "Docker image built successfully"
            }
        }
        
        stage('Push to Registry') {
            when {
                // Only push if not a pull request
                not { changeRequest() }
            }
            steps {
                echo "Pushing Docker image to registry..."
                sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                echo "Docker image pushed successfully"
            }
        }
    }
    
    post {
        always {
            // Archive build artifacts
            archiveArtifacts artifacts: '**/*.log, **/target/*.jar, **/dist/*, **/build/*, **/snyk-results.json', 
                            fingerprint: true,
                            allowEmptyArchive: true
            
            // Clean workspace
            cleanWs()
        }
        
        success {
            echo "Pipeline executed successfully!"
            // Send success notification (optional)
        }
        
        failure {
            echo "Pipeline failed!"
            // Send failure notification (optional)
        }
        
        unstable {
            echo "Pipeline completed with warnings!"
        }
    }
}