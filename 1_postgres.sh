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
#==========================
echo
echo "=== Формирование переменных окружения ==="
cp /home/$your_user/PostgreSQL_VPS/.env_example /home/$your_user/PostgreSQL_VPS/.env

echo 
read -p "=== Задать имя пользователя БД [postgres]: " POSTGRES_USER
if [ ! -z $POSTGRES_USER ]
then
    echo "POSTGRES_USER=$POSTGRES_USER" > /home/$your_user/PostgreSQL_VPS/.env
else
    echo "POSTGRES_USER=postgres" > /home/$your_user/PostgreSQL_VPS/.env
fi

echo 
read -p "=== Задать пароль для БД (не менее 8 символов)[changeme]: " POSTGRES_PASSWORD
if [ ! -z $POSTGRES_PASSWORD ]
then
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> /home/$your_user/PostgreSQL_VPS/.env
else
    echo "POSTGRES_PASSWORD=changeme" >> /home/$your_user/PostgreSQL_VPS/.env
fi

echo "POSTGRES_PORT=5432" >> /home/$your_user/PostgreSQL_VPS/.env
echo "ADMINER_PORT=8080" >> /home/$your_user/PostgreSQL_VPS/.env
echo "PGADMIN_PORT=5050" >> /home/$your_user/PostgreSQL_VPS/.env

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
echo "===       PgAdmin по адресу: http://$ip_addr:5050      ==="
echo "===         Add a new server in PgAdmin:                   ==="
echo "=== Host name/address: $ip_addr                        ==="
echo "=== Port as 'POSTGRES_PORT', by default: '5432'            ==="
echo "=== Username as 'POSTGRES_USER', by default: 'postgres'    ==="
echo "=== Password as 'POSTGRES_PASSWORD', by default 'changeme' ==="
echo "=============================================================="
echo "===       Adminer по адресу: http://$ip_addr:8080      ==="
echo "=== System: 'PostgreSQL'                                   ==="
echo "=== Server: $ip_addr                                   ==="
echo "=== Username as 'POSTGRES_USER', by default: 'postgres'    ==="
echo "=== Password as 'POSTGRES_PASSWORD', by default 'changeme' ==="
echo "=== Database: 'postgres' или пусто                         ==="
echo "=============================================================="
echo
echo "======================================================="
echo "===    Для смены настроек перейдите в папку:        ==="
echo "===     cd  /home/$your_user/PostgreSQL_VPS/             ==="
echo "=== Остановите все контейнеры (БД удалятся!):       ==="
echo "===      $ docker compose down --volumes            ==="
echo "=== Отредактируйте файл: .env                       ==="
echo "=== Запустите контейнеры: $ docker compose up -d    ==="
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

