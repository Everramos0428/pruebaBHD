#!/bin/bash

# Actualizar la lista de paquetes disponibles
apt update

# Instalar dependencias necesarias para Docker, Git y otras utilidades
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common git

# Instalar Docker
# Descargar la clave GPG oficial de Docker y agregarla al sistema
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Agregar el repositorio de Docker a las fuentes de apt
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Actualizar la lista de paquetes con el nuevo repositorio de Docker
apt update

# Instalar la versión de Docker Community Edition (CE)
apt install -y docker-ce


# Configurar SonarQube
# Ajustar configuraciones de kernel para SonarQube
sysctl -w vm.max_map_count=524288   # Incrementar el límite máximo de mapeos de memoria virtual
sysctl -w fs.file-max=131072        # Incrementar el número máximo de descriptores de archivo
ulimit -n 131072                    # Incrementar el número máximo de archivos abiertos
ulimit -u 8192                      # Incrementar el número máximo de procesos de usuario

# Clonar el repositorio de SonarQube desde GitHub
git clone https://github.com/SonarSource/sonarqube.git

# SonarQube y PostgreSQL
bin/linux-x86-64/sonar.sh start
