/**
 * Jenkins Pipeline for CI/CD
 * 
 * This pipeline automates the build, test, and deployment process
 * for the sample web application to Kubernetes cluster.
 * 
 * Pipeline Stages:
 * 1. Checkout - Get code from Git repository
 * 2. Build - Install dependencies and prepare application
 * 3. Test - Run automated tests
 * 4. Docker Build - Create Docker image
 * 5. Docker Push - Push image to registry
 * 6. Deploy to K8s - Deploy to Kubernetes cluster
 * 7. Verify - Verify deployment success
 */

pipeline {
    agent any
    
    // Environment variables
    environment {
        // Docker configuration
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'sample-web-app'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        
        // Kubernetes configuration
        K8S_NAMESPACE = 'default'
        K8S_DEPLOYMENT_NAME = 'sample-web-app'
        K8S_CREDENTIALS_ID = 'kubeconfig-credentials'
        
        // Application configuration
        APP_NAME = 'sample-web-app'
        PORT = '3000'
        
        // Git configuration
        GIT_CREDENTIALS_ID = 'git-credentials'
    }
    
    // Build triggers
    triggers {
        // Poll SCM every 5 minutes for changes
        pollSCM('H/5 * * * *')
        
        // Or use webhook trigger (recommended)
        // GitHub webhook should be configured in GitHub repository settings
    }
    
    // Pipeline options
    options {
        // Keep last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout for entire pipeline
        timeout(time: 30, unit: 'MINUTES')
        
        // Disable concurrent builds
        disableConcurrentBuilds()
        
        // Timestamps in console output
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 1: Checking out code from Git'
                    echo '========================================='
                    
                    try {
                        // Checkout code from Git repository
                        checkout scm
                        
                        // Get commit information
                        env.GIT_COMMIT_MSG = sh(
                            script: 'git log -1 --pretty=%B',
                            returnStdout: true
                        ).trim()
                        
                        env.GIT_AUTHOR = sh(
                            script: 'git log -1 --pretty=%an',
                            returnStdout: true
                        ).trim()
                        
                        echo "✅ Checkout successful"
                        echo "Commit: ${env.GIT_COMMIT_MSG}"
                        echo "Author: ${env.GIT_AUTHOR}"
                    } catch (Exception e) {
                        echo "❌ Checkout failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 2: Building application'
                    echo '========================================='
                    
                    try {
                        // Install Node.js dependencies
                        sh '''
                            echo "Installing dependencies..."
                            npm ci
                            echo "✅ Dependencies installed successfully"
                        '''
                    } catch (Exception e) {
                        echo "❌ Build failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 3: Running tests'
                    echo '========================================='
                    
                    try {
                        // Run tests
                        sh '''
                            echo "Running unit tests..."
                            npm test
                            echo "✅ All tests passed"
                        '''
                    } catch (Exception e) {
                        echo "❌ Tests failed: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                        throw e
                    }
                }
            }
            post {
                always {
                    // Publish test results (if using JUnit format)
                    // junit 'test-results/**/*.xml'
                    echo "Test stage completed"
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 4: Building Docker image'
                    echo '========================================='
                    
                    try {
                        // Build Docker image
                        env.FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        
                        sh """
                            echo "Building Docker image: ${FULL_IMAGE_NAME}"
                            docker build -t ${FULL_IMAGE_NAME} .
                            docker tag ${FULL_IMAGE_NAME} ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest
                            echo "✅ Docker image built successfully"
                        """
                    } catch (Exception e) {
                        echo "❌ Docker build failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 5: Pushing Docker image to registry'
                    echo '========================================='
                    
                    try {
                        // Push Docker image to registry
                        withCredentials([usernamePassword(
                            credentialsId: DOCKER_CREDENTIALS_ID,
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )]) {
                            sh """
                                echo "Logging in to Docker registry..."
                                echo \$DOCKER_PASSWORD | docker login ${DOCKER_REGISTRY} -u \$DOCKER_USERNAME --password-stdin
                                
                                echo "Pushing image: ${FULL_IMAGE_NAME}"
                                docker push ${FULL_IMAGE_NAME}
                                docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest
                                
                                echo "✅ Docker image pushed successfully"
                                docker logout ${DOCKER_REGISTRY}
                            """
                        }
                    } catch (Exception e) {
                        echo "❌ Docker push failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 6: Deploying to Kubernetes'
                    echo '========================================='
                    
                    try {
                        // Deploy to Kubernetes using kubectl
                        withCredentials([file(
                            credentialsId: K8S_CREDENTIALS_ID,
                            variable: 'KUBECONFIG'
                        )]) {
                            sh """
                                echo "Deploying to Kubernetes cluster..."
                                
                                # Apply Kubernetes manifests
                                kubectl apply -f k8s/deployment.yaml --kubeconfig=\$KUBECONFIG
                                kubectl apply -f k8s/service.yaml --kubeconfig=\$KUBECONFIG
                                
                                # Update image in deployment
                                kubectl set image deployment/${K8S_DEPLOYMENT_NAME} \
                                    ${APP_NAME}=${FULL_IMAGE_NAME} \
                                    -n ${K8S_NAMESPACE} \
                                    --kubeconfig=\$KUBECONFIG
                                
                                echo "✅ Deployment initiated successfully"
                            """
                        }
                    } catch (Exception e) {
                        echo "❌ Kubernetes deployment failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo '========================================='
                    echo 'Stage 7: Verifying deployment'
                    echo '========================================='
                    
                    try {
                        // Verify deployment status
                        withCredentials([file(
                            credentialsId: K8S_CREDENTIALS_ID,
                            variable: 'KUBECONFIG'
                        )]) {
                            sh """
                                echo "Waiting for deployment to be ready..."
                                kubectl rollout status deployment/${K8S_DEPLOYMENT_NAME} \
                                    -n ${K8S_NAMESPACE} \
                                    --timeout=5m \
                                    --kubeconfig=\$KUBECONFIG
                                
                                echo "Checking pod status..."
                                kubectl get pods -n ${K8S_NAMESPACE} -l app=${APP_NAME} --kubeconfig=\$KUBECONFIG
                                
                                echo "✅ Deployment verified successfully"
                            """
                        }
                    } catch (Exception e) {
                        echo "❌ Deployment verification failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
    }
    
    // Post-build actions
    post {
        success {
            echo '========================================='
            echo '✅ Pipeline completed successfully!'
            echo '========================================='
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Docker Image: ${FULL_IMAGE_NAME}"
            echo "Deployed to: ${K8S_NAMESPACE} namespace"
            
            // Send notification (configure email/Slack/etc.)
            // emailext subject: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //          body: "Build completed successfully!",
            //          to: "team@example.com"
        }
        
        failure {
            echo '========================================='
            echo '❌ Pipeline failed!'
            echo '========================================='
            
            // Send failure notification
            // emailext subject: "❌ Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            //          body: "Build failed. Please check the logs.",
            //          to: "team@example.com"
        }
        
        always {
            echo '========================================='
            echo 'Cleaning up...'
            echo '========================================='
            
            // Clean up Docker images to save space
            sh """
                docker image prune -f || true
            """
            
            // Archive artifacts if needed
            // archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
        }
    }
}
