#!/bin/bash

# Verifica se o docker e o git estão instalados
if ! command -v docker &> /dev/null
then
    read -p "O docker não está instalado. Deseja instalá-lo? (y/n): " INSTALL_DOCKER
    if [[ $INSTALL_DOCKER == "y" || $INSTALL_DOCKER == "Y" ]]
    then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
    else
        echo "O docker não está instalado. O script não pode ser executado."
        exit 1
    fi
fi

if ! command -v git &> /dev/null
then
    read -p "O git não está instalado. Deseja instalá-lo? (y/n): " INSTALL_GIT
    if [[ $INSTALL_GIT == "y" || $INSTALL_GIT == "Y" ]]
    then
        sudo apt-get update
        sudo apt-get install -y git
    else
        echo "O git não está instalado. O script não pode ser executado."
        exit 1
    fi
fi

# Função para verificar se o repositório zksync já foi clonado anteriormente
function check_repo {
  if [ -d "zksync" ]
  then
    echo "O repositório zksync já foi clonado anteriormente."
    return 1
  else
    echo "Clonando o repositório zksync do GitHub..."
    git clone https://github.com/matter-labs/zksync.git
  fi
}

cd zksync

# Seleciona a rede de testes Mumbai
sed -i "s/NETWORK_NAME = Network::Mainnet/NETWORK_NAME = Network::Mumbai/g" core/lib/storage/operations.rb

# Cria uma nova imagem a partir do Dockerfile
docker build -t zksync-node .

# Cria um arquivo docker-compose.yml na pasta do projeto com as configurações necessárias
echo "version: '3.8'
services:
  zksync-node:
    image: zksync-node
    environment:
      NETWORK: $NETWORK
      PROVIDER_URL: $PROVIDER_URL
      WEB3_URL: $WEB3_URL
    ports:
      - \"3030:3030\"" > docker-compose.yml

# Inicia o contêiner usando o docker-compose
read -p "Deseja iniciar o contêiner do node de zkSync? (y/n): " START_CONTAINER
if [[ $START_CONTAINER == "y" || $START_CONTAINER == "Y" ]]
then
    docker-compose up -d
    echo "O contêiner do node de zkSync foi iniciado com sucesso!"
    echo "Acesse a interface do zkSync no endereço http://localhost:3030/."
else
    echo "O contêiner do node de zkSync não foi iniciado. Execute \"docker-compose up\" na pasta do projeto para iniciar o contêiner manualmente."
fi

exit 0
