pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${env.PATH}"
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }
    
    stages {
        // ========================================
        // STAGE 1: CODE CHECKOUT
        // ========================================
        stage('1️⃣ Checkout Code') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }
        
        // ========================================
        // STAGE 2: SETUP CREDENTIALS
        // ========================================
        stage('2️⃣ Setup SSH Key') {
            steps {
                echo '🔑 Setting up SSH key for infrastructure access...'
                script {
                    sh '''#!/bin/bash
                        if [ ! -f devops.pem ]; then
                            if [ -f ~/.ssh/devops.pem ]; then
                                cp ~/.ssh/devops.pem .
                                chmod 600 devops.pem
                                echo "✅ SSH key copied successfully"
                            else
                                echo "❌ ERROR: SSH key not found at ~/.ssh/devops.pem"
                                exit 1
                            fi
                        else
                            echo "✅ SSH key already exists in workspace"
                        fi
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 3: TERRAFORM INITIALIZATION
        // ========================================
        stage('3️⃣ Terraform Init') {
            steps {
                dir('terraform') {
                    echo '🔧 Initializing Terraform backend and providers...'
                    sh '#!/bin/bash\nterraform init'
                }
            }
        }
        
        // ========================================
        // STAGE 4: TERRAFORM PLAN
        // ========================================
        stage('4️⃣ Terraform Plan') {
            steps {
                dir('terraform') {
                    echo '📋 Creating Terraform execution plan...'
                    sh '''#!/bin/bash
                        terraform plan -out=tfplan
                        echo ""
                        echo "=== Plan Summary ==="
                        terraform show tfplan | grep -E "Plan:|No changes"
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 5: TERRAFORM VALIDATE & APPROVE
        // ========================================
        stage('5️⃣ Approve Terraform Plan') {
            steps {
                script {
                    echo '⏸️  Waiting for manual approval to apply Terraform plan...'
                    input message: 'Review the Terraform plan above. Proceed with infrastructure creation?', 
                          ok: 'Yes, Create Infrastructure'
                }
            }
        }
        
        // ========================================
        // STAGE 6: TERRAFORM APPLY (INFRASTRUCTURE ONLY)
        // ========================================
        stage('6️⃣ Terraform Apply - Infrastructure') {
            steps {
                dir('terraform') {
                    echo '🏗️  Creating AWS infrastructure (EC2 instances, VPC, Security Groups)...'
                    sh '#!/bin/bash\nterraform apply -auto-approve tfplan'
                }
            }
        }
        
        // ========================================
        // STAGE 7: WAIT FOR INSTANCES TO BE READY
        // ========================================
        stage('7️⃣ Wait for AWS Instances') {
            steps {
                echo '⏳ Waiting for EC2 instances to be fully ready...'
                script {
                    sh '''#!/bin/bash
                        echo "Sleeping for 30 seconds to allow instances to initialize..."
                        sleep 30
                        
                        cd playbooks
                        if [ -f aws_hosts ]; then
                            echo ""
                            echo "=== Checking Instance Connectivity ==="
                            while IFS= read -r line; do
                                if [[ $line =~ ^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$ ]]; then
                                    echo "Testing SSH connection to $line..."
                                    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ../devops.pem ubuntu@$line "echo 'Connected successfully'" && echo "✅ $line is ready" || echo "⚠️  $line not ready yet"
                                fi
                            done < aws_hosts
                        else
                            echo "❌ ERROR: aws_hosts inventory file not found"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 8: VALIDATE ANSIBLE INVENTORY
        // ========================================
        stage('8️⃣ Validate Ansible Inventory') {
            steps {
                echo '📝 Validating Ansible inventory and configuration...'
                dir('playbooks') {
                    sh '''#!/bin/bash
                        if [ ! -f aws_hosts ]; then
                            echo "❌ ERROR: Inventory file 'aws_hosts' not found"
                            exit 1
                        fi
                        
                        echo "=== Ansible Inventory ==="
                        cat aws_hosts
                        
                        echo ""
                        echo "=== Ansible Version ==="
                        ansible --version
                        
                        echo ""
                        echo "=== Testing Ansible Ping ==="
                        ANSIBLE_CONFIG=./ansible.cfg ansible all -i aws_hosts -m ping || echo "⚠️  Some hosts not responding yet"
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 9: APPROVE ANSIBLE CONFIGURATION
        // ========================================
        stage('9️⃣ Approve Ansible Configuration') {
            steps {
                script {
                    echo '⏸️  Waiting for approval to run Ansible playbooks...'
                    input message: 'Infrastructure is ready. Proceed with Grafana and Prometheus installation?', 
                          ok: 'Yes, Run Ansible Playbooks'
                }
            }
        }
        
        // ========================================
        // STAGE 10: ANSIBLE - INSTALL GRAFANA
        // ========================================
        stage('🔟 Ansible - Install Grafana') {
            steps {
                echo '📊 Installing Grafana on EC2 instances...'
                dir('playbooks') {
                    sh '''#!/bin/bash
                        ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i aws_hosts grafana.yaml -v
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 11: ANSIBLE - INSTALL PROMETHEUS
        // ========================================
        stage('1️⃣1️⃣ Ansible - Install Prometheus') {
            steps {
                echo '📈 Installing Prometheus and Node Exporter on EC2 instances...'
                dir('playbooks') {
                    sh '''#!/bin/bash
                        ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i aws_hosts install-prometheus.yaml -v
                    '''
                }
            }
        }
        
        // ========================================
        // STAGE 12: DEPLOYMENT VERIFICATION
        // ========================================
        stage('1️⃣2️⃣ Verify Deployment') {
            steps {
                echo '✅ Verifying complete deployment...'
                dir('terraform') {
                    script {
                        sh '''#!/bin/bash
                            echo "=== 📋 Deployed Infrastructure ==="
                            terraform output -json | jq -r '.instance_details.value[] | "\\n🖥️  Instance: \\(.name)\\n   IP Address: \\(.ip)\\n   Availability Zone: \\(.zone)"'
                            
                            echo ""
                            echo "=== 🌐 Access URLs ==="
                            terraform output -json | jq -r '.instance_details.value[] | "\\n📊 Grafana: http://\\(.ip):3000\\n   Username: admin\\n   Password: admin\\n\\n📈 Prometheus: http://\\(.ip):9090\\n   (No authentication required)"'
                            
                            echo ""
                            echo "=== 🔍 Service Health Check ==="
                            for ip in $(terraform output -json | jq -r '.instance_details.value[].ip'); do
                                echo "Checking Grafana on $ip:3000..."
                                curl -s -o /dev/null -w "Status: %{http_code}\\n" --connect-timeout 5 http://$ip:3000 || echo "Not accessible yet"
                                
                                echo "Checking Prometheus on $ip:9090..."
                                curl -s -o /dev/null -w "Status: %{http_code}\\n" --connect-timeout 5 http://$ip:9090 || echo "Not accessible yet"
                            done
                        '''
                    }
                }
            }
        }
        
        
        // ========================================
        // STAGE 13: APPROVE DESTROY (OPTIONAL)
        // ========================================
        stage('1️⃣3️⃣ Approve Destroy') {
            steps {
                script {
                    echo '⏸️  Waiting for approval to destroy infrastructure...'
                    input message: '⚠️  Do you want to DESTROY all resources?', 
                          ok: 'Yes, Destroy Everything'
                }
            }
        }
        
        // ========================================
        // STAGE 14: TERRAFORM DESTROY
        // ========================================
        stage('1️⃣4️⃣ Terraform Destroy') {
            steps {
                dir('terraform') {
                    echo '🗑️  Destroying all infrastructure...'
                    sh '#!/bin/bash\nterraform destroy -auto-approve'
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo '🎉 All stages executed without errors.'
        }
        failure {
            echo '❌ Pipeline failed!'
            echo '📋 Please check the logs above for error details.'
        }
        always {
            echo '🧹 Cleaning up workspace...'
            sh '''#!/bin/bash
                rm -f devops.pem || true
                rm -f terraform/tfplan || true
            '''
        }
    }
}
