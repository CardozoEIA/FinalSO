#!/bin/bash

# Detener ejecución si ocurre un error
set -e

# ==== CONFIGURACIÓN ====
AWS_REGION="us-east-1"                # Cambia por tu región
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME="mi-aplicacion"             # Cambia por el nombre de tu repositorio en ECR
IMAGE_NAME="$REPO_NAME:latest"
ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME"

echo "🔧 Construyendo imagen Docker..."
docker build -t $REPO_NAME .

echo "🏷️ Etiquetando imagen con 'latest'..."
docker tag $REPO_NAME:latest $ECR_URI

echo "🔑 Iniciando sesión en Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "⬆️ Subiendo imagen a AWS ECR..."
docker push $ECR_URI

echo "✅ Imagen subida exitosamente: $ECR_URI"
