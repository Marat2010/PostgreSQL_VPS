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
echo
usermod -aG sudo $your_user
echo "=== Пользователь '$your_user' в группе 'sudo' ==="

# === Инструкция Install Docker: https://docs.docker.com/engine/install/ubuntu/ ===
echo "=== Установка Docker, Docker-compose ==="

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg
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
echo
sudo usermod -aG docker $your_user
echo "=== Пользователь '$your_user' в группе 'docker' ==="
#==========================
echo
echo "=== Версия Docker: ==="
docker -v
echo
echo "=== Версия Docker compose: ==="
docker compose version
#==========================
echo
echo "=== Копирование 'docker-compose.yml' ==="
git clone https://github.com/Marat2010/PostgreSQL_VPS
mv PostgreSQL_VPS /home/$your_user/
chown -R $your_user:$your_user /home/$your_user/PostgreSQL_VPS

#==========================
# === Инструкция Postgresql & PgAdmin powered by compose: https://github.com/khezen/compose-postgres ===
echo
echo "=== Установка и запуск контейнеров: postgres, pgadmin, adminer ==="
sudo -u $your_user bash -c "cd /home/$your_user/PostgreSQL_VPS && docker compose up -d"
#==========================
echo
echo "=== Установка ЗАВЕРШЕНА! ==="
echo "=== Запущенные контейнеры: ==="
docker ps -a

ip_addr=`wget -q -4 -O- http://icanhazip.com`
echo
echo "=============================================================="
echo "===       PgAdmin по адресу: http://$ip_addr:5050          ==="
echo "===         Add a new server in PgAdmin:                   ==="
echo "=== Host name/address $ip_addr                             ==="
echo "=== Port as `POSTGRES_PORT`, by default: `5432`            ==="
echo "=== Username as `POSTGRES_USER`, by default: `postgres`    ==="
echo "=== Password as `POSTGRES_PASSWORD`, by default `changeme` ==="
echo "===    ==="
echo "=============================================================="
echo "===       Adminer по адресу: http://$ip_addr:8080          ==="
echo "=== System: `PostgreSQL`                                   ==="
echo "=== Server: $ip_addr                                       ==="
echo "=== Username as `POSTGRES_USER`, by default: `postgres`    ==="
echo "=== Password as `POSTGRES_PASSWORD`, by default `changeme` ==="
echo "=== Database: `postgres` или пусто                         ==="
echo "=============================================================="

echo
echo "======================================================="
echo "=== Для смены настроек отредактируйте файл:         ==="
echo "===  '/home/$your_user/PostgreSQL_VPS/.env'         ==="
echo "=== Остановите все контейнеры:                      ==="
echo "===   $ docker compose down                         ==="
echo "=== Перейдите в папку с файлом 'docker-compose.yml' ==="
echo "=== Запустите контейнеры                            ==="
echo "===   $ docker compose up -d                        ==="
echo "======================================================="
echo
echo "=== Вход под пользователем '$your_user' ==="
cd /home/$your_user && su $your_user

#===========================
# Остановка:
#    docker-compose down 
# или так для удаления томов (БД почистятся):
#    docker-compose down --volumes
#------------------
# Почистить volumes:
#    docker volume prune
#===========================

