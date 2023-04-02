#!/bin/bash
build() {
# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker não está instalado. Deseja instalá-lo? (y/n)"
    read choice
    if [ "$choice" = "y" ]; then
        echo "Instalando Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        echo "Docker instalado com sucesso."
    else
        echo "Docker não instalado. Saindo."
        exit
    fi
fi

# Clonar o repositório zksync
git clone https://github.com/defi-minds/zksync.git

# Navegar para o diretório zksync
cd zksync

# Alterar o arquivo docker-compose.yml para executar o nó da zkSync na Mumbai Testnet
sed -i 's/ETHEREUM_NETWORK=rinkeby/ETHEREUM_NETWORK=mumbai/g' docker-compose.yml
sed -i 's/PROVIDER_ENDPOINT=https:\/\/rinkeby.infura.io/PROVIDER_ENDPOINT=https:\/\/rpc-mumbai.maticvigil.com/g' docker-compose.yml
sed -i 's/POSTGRES_DB=zksync_rinkeby/POSTGRES_DB=zksync_mumbai/g' docker-compose.yml

# Iniciar o contêiner do nó da zkSync
docker-compose up
}
build
