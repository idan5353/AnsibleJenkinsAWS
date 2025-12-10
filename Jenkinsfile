pipeline {
    agent any
    
    stages {
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Ansible Configuration') {
            steps {
                dir('ansible') {
                    sh 'sleep 60'
                    sh 'ansible-playbook -i inventory.ini playbooks/site.yml'
                }
            }
        }
    }
}
