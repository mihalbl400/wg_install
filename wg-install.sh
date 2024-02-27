#!/bin/bash

apt update
apt install git curl wget -y

if [ -x "$(command -v docker)" ]; then
    echo "Docker installed"
    docker stop wg-easy
    docker rm wg-easy
    # command
else
    echo "Docker install"
    bash <(curl -sSL https://get.docker.com)
    # command
fi

rm -rf /opt/wg-easy/

cd /opt/

git clone https://github.com/wg-easy/wg-easy.git
cd ./wg-easy/

rm ./.env
echo "PUID=1000" >> .env
echo "PGID=1000" >> .env
echo "TZ=Etc/UTC" >> .env
echo "WG_HOST=" >> .env
echo "WG_PORT=" >> .env
echo "WG_UI_PORT=" >> .env
echo "WG_UI_PASSWORD=" >> .env
echo "WG_DEFAULT_DNS=" >> .env
echo "WG_DEFAULT_ADDRESS=10.13.12.x" >> .env
echo "WG_PERSISTENT_KEEPALIVE=25" >> .env


extaddr=$(curl -s https://checkip.amazonaws.com)

read -rp "External IP: " -e -i $extaddr WG_HOST
read -rp "WG port: " -e -i "61820" WG_PORT
read -rp "WG WebUI port: " -e -i "61821" WG_UI_PORT
read -rp "Password: " -e -i "foobar12345#" WG_UI_PASSWORD
read -rp "Default DNS: " -e -i "1.1.1.1, 1.0.0.1" WG_DEFAULT_DNS
read -rp "Default address: " -e -i "10.13.12.x" WG_DEFAULT_ADDRESS

sed -i 's:^WG_HOST=.*:WG_HOST='$WG_HOST':' ./.env
sed -i 's:^WG_UI_PASSWORD=.*:WG_UI_PASSWORD='$WG_UI_PASSWORD':' ./.env
sed -i 's:^WG_PORT=.*:WG_PORT='$WG_PORT':' ./.env
sed -i 's:^WG_UI_PORT=.*:WG_UI_PORT='$WG_UI_PORT':' ./.env

sed -i '/WG_DEFAULT_DNS/d' ./.env
echo "WG_DEFAULT_DNS=$WG_DEFAULT_DNS" >> ./.env

sed -i '/WG_DEFAULT_ADDRESS/d' ./.env
echo "WG_DEFAULT_ADDRESS=$WG_DEFAULT_ADDRESS" >> ./.env

#cp ./docker-compose.yml ./docker-compose.yml.base
rm ./docker-compose.yml
wget https://raw.githubusercontent.com/wg-easy/wg-easy/master/docker-compose.yml

sed -i 's:- LANG=.*:- LANG=ru:' ./docker-compose.yml
sed -i 's:- WG_HOST=.*:- WG_HOST=${WG_HOST}:' ./docker-compose.yml
sed -i 's:# - WG_PORT=.*:- WG_PORT=${WG_PORT}:' ./docker-compose.yml
sed -i 's:# - PASSWORD=.*:- PASSWORD=${WG_UI_PASSWORD}:' ./docker-compose.yml
sed -i 's:# - WG_DEFAULT_DNS=.*:- WG_DEFAULT_DNS=${WG_DEFAULT_DNS}:' ./docker-compose.yml
sed -i 's:# - WG_PERSISTENT_KEEPALIVE=.*:- WG_PERSISTENT_KEEPALIVE=${WG_PERSISTENT_KEEPALIVE}:' ./docker-compose.yml
sed -i 's:# - WG_DEFAULT_ADDRESS=.*:- WG_DEFAULT_ADDRESS=${WG_DEFAULT_ADDRESS}:' ./docker-compose.yml
sed -i 's:- "51820:- "${WG_PORT}:' ./docker-compose.yml
sed -i 's:- "51821:- "${WG_UI_PORT}:' ./docker-compose.yml


docker compose up -d --build

echo -e "Your VPN URL: http://$WG_HOST:$WG_UI_PORT"
echo -e "Password: $WG_UI_PASSWORD"
