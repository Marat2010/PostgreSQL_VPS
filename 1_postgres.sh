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
echo
# === Инструкция Install Docker: https://docs.docker.com/engine/install/ubuntu/ ===
echo "=== Установка Docker, Docker-compose ==="
echo
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
mkdir /home/$your_user/PostgreSQL_VPS
wget -O /home/$your_user/PostgreSQL_VPS/docker-compose.yml https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/secure/docker-compose.yml
wget -O /home/$your_user/PostgreSQL_VPS/.env_example https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/secure/.env_example
#==========================
echo
echo "=== Формирование переменных окружения ==="
touch /home/$your_user/PostgreSQL_VPS/.env
#--------------------------
echo 
read -p "=== Задать имя пользователя БД [postgres]: " POSTGRES_USER
if [ -z $POSTGRES_USER ]
then
    POSTGRES_USER="postgres"
fi
#--------------------------
echo 
read -p "=== Задать пароль для БД [changeme]: " POSTGRES_PASSWORD
if [ -z $POSTGRES_PASSWORD ]
then
    POSTGRES_PASSWORD="changeme"
fi
#--------------------------
echo 
read -p "=== Порт PostgreSQL [5432]: " POSTGRES_PORT
if [ -z $POSTGRES_PORT ]
then
    POSTGRES_PORT=5432
fi
#--------------------------
echo 
read -p "=== Порт pgAdmin-а [5050]: " PGADMIN_PORT
if [ -z $PGADMIN_PORT ]
then
    PGADMIN_PORT=5050
fi
#--------------------------
echo 
read -p "=== Порт Adminer-а [8080]: " ADMINER_PORT
if [ -z $ADMINER_PORT ]
then
    ADMINER_PORT=8080
fi
#--------------------------
echo "POSTGRES_USER=$POSTGRES_USER" > /home/$your_user/PostgreSQL_VPS/.env
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> /home/$your_user/PostgreSQL_VPS/.env
echo "POSTGRES_PORT=$POSTGRES_PORT" >> /home/$your_user/PostgreSQL_VPS/.env
echo "PGADMIN_PORT=$PGADMIN_PORT" >> /home/$your_user/PostgreSQL_VPS/.env
echo "ADMINER_PORT=$ADMINER_PORT" >> /home/$your_user/PostgreSQL_VPS/.env

chmod 600 /home/$your_user/PostgreSQL_VPS/.env
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

IP_public=`wget -q -4 -O- http://icanhazip.com`
Container_Postgres_name="postgres_cont"
IP_Postgres=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container_Postgres_name`
#IP_public=`curl http://icanhazip.com`
echo
echo "=============================================================="
echo "===    PgAdmin по адресу: http://$IP_public:$PGADMIN_PORT    "
echo "===      Add a new server in PgAdmin:                   "
echo "=== Host name/address: 'postgres' или $IP_Postgres      "
echo "=== Port as 'POSTGRES_PORT': 5432                       "
echo "=== Username as 'POSTGRES_USER': $POSTGRES_USER         "
echo "=== Password as 'POSTGRES_PASSWORD': $POSTGRES_PASSWORD "
echo "=============================================================="
echo "===    Adminer по адресу: http://$IP_public:$ADMINER_PORT     "
echo "=== System: 'PostgreSQL'                                "
echo "=== Server: 'postgres' или $IP_Postgres                 "
echo "=== Username as 'POSTGRES_USER': $POSTGRES_USER         "
echo "=== Password as 'POSTGRES_PASSWORD': $POSTGRES_PASSWORD "
echo "=== Database: пусто                                     "
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

