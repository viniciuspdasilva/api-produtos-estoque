#!/bin/bash

echo "🚀 Iniciando deploy via Contêiner..."

echo "Parando contêiner antigo..."
sudo docker stop api-container || true
sudo docker rm api-container || true

echo "Construindo nova imagem Docker..."
sudo docker build -t api-produtos:latest .

# 3. Inicia o novo contêiner mapeando a porta 8080
echo "Subindo o novo contêiner..."
sudo docker run -d --name api-container -p 8080:8080 api-produtos:latest

# 4. Limpeza de disco (remove imagens antigas soltas)
sudo docker image prune -f

echo "✅ Deploy finalizado com sucesso! API rodando na porta 8080."