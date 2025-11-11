#!/bin/bash

# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar python3, pip y venv si no están
sudo apt install python3 python3-venv python3-pip unzip curl git -y

# Clonar repo de GitHub (si no existe)
if [ ! -d ~/fastapi_app ]; then
    git clone https://github.com/CardozoEIA/PracticaSO.git ~/fastapi_app
else
    echo "Repo ya existe, saltando clone"
fi

# Ir a la carpeta del proyecto
cd ~/fastapi_app

# Crear entorno virtual
python3 -m venv venv

# Activar entorno
source venv/bin/activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Copiar servicio systemd (asegúrate de que fastapi.srv exista aquí)
sudo cp fastapi.srv /etc/systemd/system/fastapi.service
sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl start fastapi

# Verificar estado
sudo systemctl status fastapi
