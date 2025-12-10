resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-17-jdk wget gnupg
              
              # Install Jenkins
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
              sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              apt-get update
              apt-get install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins
              
              # Install Terraform
              wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
              apt-get install -y unzip
              unzip terraform_1.6.0_linux_amd64.zip
              mv terraform /usr/local/bin/
              
              # Install Ansible
              apt-get install -y ansible
              
              # Allow Jenkins user to run commands
              usermod -aG sudo jenkins
              EOF

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}
