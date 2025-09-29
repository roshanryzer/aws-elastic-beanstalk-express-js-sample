pipeline {
    agent {
        docker {
            image 'node:16'
            args '-u root:root'
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'npm install -g snyk'
                sh 'snyk test --severity-threshold=high'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }
        
        stage('Push to Registry') {
            steps {
                sh 'docker push myapp:${BUILD_NUMBER}'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}