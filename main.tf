# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "Tf-jen"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-08eb150f611ca277f"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"  # Using t3.micro as it's available in eu-north-1
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
  default     = "subnet-00a63f93309e4ff71"
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-02fc1aac149ca551e"
}

# provider.tf
provider "aws" {
  region = var.aws_region
}

# main.tf
# Security Group
resource "aws_security_group" "tf_jen_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = var.vpc_id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow Jenkins port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins access"
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Allow HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = "Development"
  }
}

# EC2 Instance
resource "aws_instance" "tf_jen_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.tf_jen_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Java
              sudo apt update
              sudo apt install -y openjdk-17-jdk

              # Install Jenkins
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update
              sudo apt install -y jenkins

              # Start Jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = {
    Name        = var.instance_name
    Environment = "Development"
    Terraform   = "true"
    Purpose     = "Jenkins Server"
  }
}

# outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.tf_jen_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.tf_jen_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.tf_jen_instance.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.tf_jen_sg.id
}

output "jenkins_initial_password_command" {
  description = "Command to get Jenkins initial admin password"
  value       = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}
