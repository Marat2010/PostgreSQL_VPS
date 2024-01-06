#!/bin/bash

# === Смена пароля root-а ===

echo 
read -p "=== Сменить у пользователя 'root' пароль? [y/N]: " change_passwd_root

if [ "$change_passwd_root" == "y" ]
then
    passwd root
fi

# === Добавление и настройка пользователя ===

echo
read -p "=== Введите имя пользователя: " your_user
adduser --gecos "" $your_user

usermod -aG sudo $your_user
echo "=== Пользователь '$your_user' в группе 'sudo' ==="

#==========================

su $your_user
cd ~

# === Install Docker: https://docs.docker.com/engine/install/ubuntu/ ===

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#==========================
#sudo usermod -aG docker $USER
sudo usermod -aG docker $USER
echo "=== Пользователь '$your_user' в группе 'docker' ==="
#==========================
echo "=== Версия Docker: ==="
docker -v
echo "=== Версия Docker compose: ==="
docker compose version
#==========================
echo
echo "=== Копирование 'docker-compose.yml' в каталог пользователя '$proj_user' ==="

git clone https://github.com/Marat2010/PostgreSQL_VPS
#==========================

#Запуск:
echo "=== Установка и запуск контейнеров: postgres, adminer, pgadmin ==="
cd PostgreSQL_VPS
docker compose up -d
#==========================
echo "=== Установка ЗАВЕРШЕНА! ==="
echo "=== PgAdmin по адресу: https://IP:50050 ==="
echo "=== Adminer по адресу: https://IP:80080 ==="
#-----------------
#Остановка:
#    docker-compose down 
#или так для удаления томов (БД почистятся):
#    docker-compose down --volumes
#------------------
#Почистить volumes:
#    docker volume prune
#===========================
