# terraform/main.tf

# 1.Aws provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 2.Firewall configuration

resource "aws_security_group" "api_sg" {
  name = "api-produtos-sg"
  description = "Regras de rede para a API de Produtos"

  ingress {
    description = "SSH Access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite acesso HTTP na porta do Quarkus (8080)
  ingress {
    description = "Acesso a API Quarkus"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite que o servidor acesse a internet (para baixar pacotes/Docker)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Criação do Servidor (Instância EC2)
resource "aws_instance" "api_server" {
  ami           = "ami-0c7217cdde317cfec" # Imagem oficial do Ubuntu Server 22.04 LTS
  instance_type = "t2.micro"              # Elegível ao Free Tier

  # Associa o firewall criado acima a este servidor
  vpc_security_group_ids = [aws_security_group.api_sg.id]

  tags = {
    Name        = "Servidor-API-Produtos"
    Environment = "Dev"
    Project     = "Fase1-DevOps"
  }
}