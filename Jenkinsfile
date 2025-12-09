pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Setup SSH Key') {
            steps {
                echo 'Setting up SSH key for Ansible...'
                script {
                    sh '''#!/bin/bash
                        # Copy SSH key if it doesn't exist in workspace
                        if [ ! -f devops.pem ]; then
                            if [ -f ~/.ssh/devops.pem ]; then
                                cp ~/.ssh/devops.pem .
                                chmod 600 devops.pem
                            else
                                echo "WARNING: SSH key not found. Ansible provisioning may fail."
                            fi
                        fi
                    '''
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    echo 'Initializing Terraform...'
                    sh '#!/bin/bash\nterraform init'
                }
            }
        }
        
        // ========================================
        // APPLY STAGES (Comment out to disable)
        // ========================================
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    echo 'Planning Terraform changes...'
                    sh '#!/bin/bash\nterraform plan -out=tfplan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    echo 'Applying Terraform changes...'
                    sh '#!/bin/bash\nterraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                dir('terraform') {
                    script {
                        sh '''#!/bin/bash
                            echo "=== Deployed Instances ==="
                            terraform output -json | jq -r '.instance_details.value[] | "Instance: \\(.name) | IP: \\(.ip) | Zone: \\(.zone)"'
                            echo ""
                            echo "=== Access URLs ==="
                            terraform output -json | jq -r '.instance_details.value[] | "Grafana: http://\\(.ip):3000 (admin/admin)"'
                            terraform output -json | jq -r '.instance_details.value[] | "Prometheus: http://\\(.ip):9090"'
                        '''
                    }
                }
            }
        }
        
        // ========================================
        // DESTROY STAGE (Uncomment to enable)
        // ========================================
        
        // stage('Terraform Destroy') {
        //     steps {
        //         dir('terraform') {
        //             echo 'Destroying all Terraform resources...'
        //             sh '#!/bin/bash\nterraform destroy -auto-approve'
        //         }
        //     }
        // }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo 'Grafana and Prometheus have been deployed.'
        }
        failure {
            echo '❌ Pipeline failed! Check the logs above.'
        }
        always {
            echo 'Cleaning up workspace...'
            // Optional: Clean up sensitive files
            sh '#!/bin/bash\nrm -f devops.pem || true'
        }
    }
}
