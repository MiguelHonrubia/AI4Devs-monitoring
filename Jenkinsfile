pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION = '1.5.0'
    }

    stages {
        stage('Install Dependencies') {
            parallel {
                stage('Backend') {
                    steps {
                        dir('backend') {
                            sh 'npm install'
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        dir('frontend') {
                            sh 'npm install'
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            parallel {
                stage('Backend Tests') {
                    steps {
                        dir('backend') {
                            sh 'npm run test'
                        }
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        dir('frontend') {
                            sh 'npm run test'
                        }
                    }
                }
            }
        }

        stage('Build Applications') {
            parallel {
                stage('Build Backend') {
                    steps {
                        dir('backend') {
                            sh 'npm run build'
                        }
                    }
                }
                stage('Build Frontend') {
                    steps {
                        dir('frontend') {
                            sh 'npm run build'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                not { branch 'main' }
            }
            steps {
                dir('tf') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: 'DATADOG_API_KEY', variable: 'TF_VAR_datadog_api_key'),
                        string(credentialsId: 'DATADOG_APP_KEY', variable: 'TF_VAR_datadog_app_key')
                    ]) {
                        sh '''
                            terraform --version
                            terraform init
                            terraform validate
                            terraform plan
                        '''
                    }
                }
            }
        }

        stage('Deploy to AWS') {
            when {
                branch 'main'
            }
            steps {
                dir('tf') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: 'DATADOG_API_KEY', variable: 'TF_VAR_datadog_api_key'),
                        string(credentialsId: 'DATADOG_APP_KEY', variable: 'TF_VAR_datadog_app_key')
                    ]) {
                        script {
                            sh '''
                                terraform --version
                                terraform init
                                terraform plan
                                terraform apply -auto-approve
                            '''
                            
                            // Capture outputs
                            def backendUrl = sh(script: 'terraform output -raw backend_url', returnStdout: true).trim()
                            def frontendUrl = sh(script: 'terraform output -raw frontend_url', returnStdout: true).trim()
                            def dashboardUrl = sh(script: 'terraform output -raw datadog_dashboard_url', returnStdout: true).trim()
                            
                            // Create deployment summary
                            echo """
                            🚀 DEPLOYMENT COMPLETED!
                            
                            📱 Application URLs:
                            - Backend API: ${backendUrl}
                            - Frontend App: ${frontendUrl}
                            
                            📊 Monitoring:
                            - Datadog Dashboard: ${dashboardUrl}
                            
                            ✅ Infrastructure deployed with monitoring enabled!
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed! Please check the logs.'
        }
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}