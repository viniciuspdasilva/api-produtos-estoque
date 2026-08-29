# terraform/main.tf

variable "ssh_public_key" {
  description = "Chave publica SSH para acessar a instancia"
  type = string
  
}

# 1.Aws provider
terraform {
  backend "s3" {
    bucket = "terraform-state-api-produtos-pucrs-2026"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
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

resource "aws_key_pair" "deployer_key" {
  key_name = "github-actions-key"
  public_key = var.ssh_public_key
}

# 2.Firewall configuration

resource "aws_security_group" "api_sg" {
  name        = "api-produtos-sg"
  description = "Regras de rede para a API de Produtos"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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
  key_name      = aws_key_pair.deployer_key.key_name


  # Adicione esta linha para garantir o IP público:
  associate_public_ip_address = true

  # -------------------------------------------------------------
  # SCRIPT DE INICIALIZAÇÃO (Bootstrapping)
  # Roda automaticamente quando a máquina é criada
  # -------------------------------------------------------------

  user_data = <<-EOF
    #!/bin/bash
    # Atualiza os pacotes do Ubuntu
    apt-get update -y

    # Instala dependências básicas
    apt-get install -y wget curl unzip

    # Instala a JDK 25 nativa do repositório oficial
    apt-get install -y openjdk-25-jdk

    # Instala o docker
    apt-get install -y docker.io

    systemctl start docker

    systemctl enable docker

    # Dá permissão para o usuário 'ubuntu' rodar o Docker
    usermod -aG docker ubuntu


  EOF

  tags = {
    Name        = "Servidor-API-Produtos"
    Environment = "Dev"
    Project     = "Fase1-DevOps"
  }
}

# Coloque isso na última linha do arquivo main.tf
output "instance_public_ip" {
  value = aws_instance.api_server.public_ip
}

