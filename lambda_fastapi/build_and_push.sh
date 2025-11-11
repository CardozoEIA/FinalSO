#!/bin/bash
set -e  # Detener ejecución si ocurre un error

# ==== CONFIGURACIÓN ====
AWS_REGION="us-east-1"                         # Región AWS
REPO_NAME="scm_finalso"                        # Nombre del repositorio en ECR
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest"

# ==== CONSTRUCCIÓN DE LA IMAGEN ====
echo "🔧 Construyendo imagen Docker para Lambda..."
docker build --platform linux/amd64 -t $REPO_NAME .

# ==== ETIQUETADO ====

docker tag $REPO_NAME:latest $ECR_URI



aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# ==== CREAR REPOSITORIO SI NO EXISTE ====
echo "🧾 Verificando si el repositorio ECR existe..."
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION >/dev/null 2>&1 || \
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

# ==== SUBIR IMAGEN ====
echo "⬆️ Subiendo imagen a ECR..."
docker push $ECR_URI

echo "✅ Imagen subida exitosamente: $ECR_URI"
