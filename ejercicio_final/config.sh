#!/bin/bash

# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar dependencias base
sudo apt install -y python3 python3-venv python3-pip unzip curl git

# Clonar o actualizar el repositorio
if [ ! -d ~/FinalSO ]; then
    echo "Clonando repositorio..."
    git clone https://github.com/CardozoEIA/FinalSO.git ~/FinalSO
else
    echo "Repositorio ya existe, actualizando..."
    cd ~/FinalSO && git pull
fi

# Ir a la carpeta correcta (donde está main.py y requirements.txt)
cd ~/FinalSO/ejercicio_final

# Crear entorno virtual
python3 -m venv venv

# Activar entorno
source venv/bin/activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Copiar servicio systemd
sudo cp fastapi.srv /etc/systemd/system/fastapi.service

# Recargar daemon y habilitar servicio
sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl restart fastapi

# Verificar estado del servicio
sudo systemctl status fastapi --no-pager
