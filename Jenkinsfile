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
        
        stage('Configure with Ansible') {
            steps {
                dir('ansible') {
                    sh '''
                        export ANSIBLE_ROLES_PATH=$(pwd)/roles
                        ansible-playbook -i inventory.ini playbooks/site.yml
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Infrastructure deployed and configured successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
