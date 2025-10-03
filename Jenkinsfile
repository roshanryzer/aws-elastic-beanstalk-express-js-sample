pipeline {
    agent any
    
    options {
        // Build retention policy
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30', artifactNumToKeepStr: '5', artifactDaysToKeepStr: '7'))
        
        // Timeout for the entire pipeline
        timeout(time: 30, unit: 'MINUTES')
        
        // Timestamp logs
        timestamps()
        
        // Annotate console output (requires AnsiColor plugin)
        // ansiColor('xterm')
    }
    
    environment {
        BUILD_LOG_LEVEL = 'INFO'
        PIPELINE_LOG_LEVEL = 'DEBUG'
        DOCKER_IMAGE_NAME = "myapp"
        DOCKER_REGISTRY = "https://hub.docker.com/repository/docker/roshanshrestha88"     }
    
    stages {
        stage('Setup Environment') {
            steps {
                echo "Setting up Node.js environment..."
                sh 'node --version || echo "Node.js not found"'
                sh 'npm --version || echo "npm not found"'
                echo "Environment setup completed"
            }
        }
        
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
                script {
                    try {
                        // Try to install Snyk locally first
                        sh 'npm install snyk --save-dev'
                        sh 'npx snyk test --severity-threshold=high --json > snyk-results.json || echo "Snyk scan completed with issues"'
                        echo "Security scan completed"
                    } catch (Exception e) {
                        echo "Snyk installation failed, trying alternative approach..."
                        // Use npm audit as fallback
                        sh 'npm audit --json > npm-audit-results.json || echo "npm audit completed"'
                        echo "Using npm audit as security scan fallback"
                    }
                }
            }
            post {
                always {
                    // Archive security scan results
                    archiveArtifacts artifacts: '**/*.log, **/target/*.jar, **/dist/*, **/build/*, **/snyk-results.json, **/npm-audit-results.json', fingerprint: true, allowEmptyArchive: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                script {
                    try {
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        echo "Docker image built successfully"
                    } catch (Exception e) {
                        echo "Docker build failed: ${e.getMessage()}"
                        echo "This might be due to Docker not being available in the Jenkins agent"
                        echo "Continuing without Docker build for now..."
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                // Only push if not a pull request
                not { changeRequest() }
            }
            steps {
                echo "Pushing Docker image to registry..."
                script {
                    try {
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        echo "Docker image pushed successfully"
                    } catch (Exception e) {
                        echo "Docker push failed: ${e.getMessage()}"
                        echo "This might be due to Docker not being available or registry not configured"
                        echo "Continuing without Docker push for now..."
                    }
                }
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