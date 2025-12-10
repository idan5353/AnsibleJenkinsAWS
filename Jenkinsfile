pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        SSH_KEY = credentials('aws-ssh-key')
        TF_PLUGIN_CACHE_DIR = "/var/lib/jenkins/.terraform.d/plugin-cache"
        HOME = "/var/lib/jenkins"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '''
                        rm -rf .terraform
                        terraform init -reconfigure
                        terraform validate
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        
        stage('Approval') {
            steps {
                input message: 'Apply Terraform changes?', ok: 'Apply'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Wait for EC2') {
            steps {
                sh 'sleep 60'
            }
        }
        
        stage('Debug Inventory') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Checking Terraform Outputs"
                    echo "======================================"
                    cd terraform
                    terraform output
                    terraform output -json
                    
                    echo ""
                    echo "======================================"
                    echo "Checking Inventory File Location"
                    echo "======================================"
                    ls -la ../ansible/ || echo "Ansible directory not found"
                    
                    echo ""
                    echo "======================================"
                    echo "Inventory File Contents"
                    echo "======================================"
                    cat ../ansible/inventory.ini || echo "Inventory file not found"
                    
                    echo ""
                    echo "======================================"
                    echo "Checking for inventory in terraform dir"
                    echo "======================================"
                    cat inventory.ini || echo "No inventory in terraform dir"
                '''
            }
        }
        
        stage('Configure with Ansible') {
            steps {
                dir('ansible') {
                    sh '''
                        # Check if inventory exists
                        if [ ! -f inventory.ini ]; then
                            echo "ERROR: Inventory file not found!"
                            exit 1
                        fi
                        
                        echo "======================================"
                        echo "Final Inventory Check"
                        echo "======================================"
                        cat inventory.ini
                        
                        echo ""
                        echo "======================================"
                        echo "Testing Ansible Connectivity"
                        echo "======================================"
                        export ANSIBLE_ROLES_PATH=$(pwd)/roles
                        export ANSIBLE_HOST_KEY_CHECKING=False
                        ansible web -m ping -i inventory.ini || echo "Ping failed, continuing anyway..."
                        
                        echo ""
                        echo "======================================"
                        echo "Running Ansible Playbook"
                        echo "======================================"
                        ansible-playbook -i inventory.ini playbooks/site.yml -vv
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Infrastructure deployed and configured successfully!'
            sh '''
                echo "======================================"
                echo "Deployment Summary"
                echo "======================================"
                cd terraform
                echo "Web Server IPs:"
                terraform output web_server_ips
                echo ""
                echo "Access your servers at:"
                terraform output -json web_server_ips | grep -oE '([0-9]{1,3}\\.){3}[0-9]{1,3}' | while read ip; do
                    echo "http://$ip"
                done
            '''
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
