#!/bin/bash

Container_Postgres_name="postgres_cont"
Container_PgAdmin_name="pgadmin_cont"
Container_Adminer_name="adminer_cont"

#IP_public=`hostname -I | cut -d' ' -f1`
IP_public=`curl http://icanhazip.com`
IP_user=`who am i --ips|awk '{print $5}'`
Docker_network=`docker network ls |grep net_postgres |awk '{print $2}'`
IP_host_docker=`docker inspect -f '{{range.IPAM.Config}}{{.Gateway}}{{end}}' $Docker_network`

IP_Postgres=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container_Postgres_name`
IP_PgAdmin=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container_PgAdmin_name`
IP_Adminer=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $Container_Adminer_name`

Port_Postgres=`ps -ax |grep docker |grep $IP_Postgres |grep 0.0.0.0 |awk '{print $11}' $Container_Postgres_name`
Port_PgAdmin=`ps -ax |grep docker |grep $IP_PgAdmin |grep 0.0.0.0 |awk '{print $11}' $Container_PgAdmin_name`
Port_Adminer=`ps -ax |grep docker |grep $IP_Adminer |grep 0.0.0.0 |awk '{print $11}' $Container_Adminer_name`

echo "IP Адрес пользователя: $IP_user"
echo "IP:Port PostgreSQL: $IP_Postgres:$Port_Postgres"
echo "IP:Port PgAdmin-a: $IP_PgAdmin:$Port_PgAdmin"
echo "IP:Port Adminer-a: $IP_Adminer:$Port_Adminer"

#============================================
echo 
read -p "=== Сбросить пароль у пользователя БД? [y/N]: " change_passwd_BD
if [ "$change_passwd_BD" == "y" ]; then
    echo 
    read -p "=== Укажите имя пользователя БД [postgres]: " POSTGRES_USER
    if [ -z $POSTGRES_USER ]; then    
        POSTGRES_USER="postgres"
    fi
    echo 
    read -p "=== Укажите новый пароль для БД [changeme]: " POSTGRES_PASSWORD
    if [ -z $POSTGRES_PASSWORD ]; then
        POSTGRES_PASSWORD="changeme"
    fi 

    docker exec postgres_cont su - $POSTGRES_USER -c "psql -U $POSTGRES_USER -d $POSTGRES_USER -c \"alter user $POSTGRES_USER with password '$POSTGRES_PASSWORD';\""
    echo "== Пользователь БД: $POSTGRES_USER , пароль: $POSTGRES_PASSWORD =="
fi

#============================================
# Перевод PgAdmin на HTTPS порт 443 (IPTABLES)
echo "PGADMIN_ENABLE_TLS=1" >> /home/$USER/PostgreSQL_VPS/.env
echo "PGADMIN_LISTEN_ADDRESS=0.0.0.0" >> /home/$USER/PostgreSQL_VPS/.env

# Формирование самоподписанных сертификатов для PgAdmin
IP_public=`wget -q -4 -O- http://icanhazip.com`
mkdir /home/$USER/PostgreSQL_VPS/pgadmin_certs
sudo openssl req -newkey rsa:2048 -sha256 -nodes -keyout /home/$USER/PostgreSQL_VPS/pgadmin_certs/server.key -x509 -days 365 -out /home/$USER/PostgreSQL_VPS/pgadmin_certs/server.cert -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=$IP_public"
sudo chmod 640 /home/$USER/PostgreSQL_VPS/pgadmin_certs/server.key

#============================================
echo 
read -p "=== Закрыть доступ к БД из интернета? [y/N]: " close_external_access
if [ "$close_external_access" == "y" ]; then  
    #------------ Редактирование postgresql.conf -----------------------------------
    path_Postgres='/var/lib/docker/volumes/postgresql_vps_postgres/_data'

    sudo cp $path_Postgres/postgresql.conf $path_Postgres/postgresql.conf_all.bak

    listen_addresses_old="listen_addresses = '\*'"
    listen_addresses_new="listen_addresses = '$IP_Postgres'"

    sudo sed -i -e "s/$listen_addresses_old/$listen_addresses_new/g" $path_Postgres/postgresql.conf

    echo "== В файле 'postgresql.conf' listen_addresses: =="
    sudo cat $path_Postgres/postgresql.conf |grep listen

    #------------ Редактирование pg_hba.conf -----------------------------------
    sudo cp $path_Postgres/pg_hba.conf $path_Postgres/pg_hba.conf_all.bak

    sudo sed -i -e "s/host /#host /g" $path_Postgres/pg_hba.conf

    echo "host  all  all  127.0.0.1/32  trust" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host  replication all 127.0.0.1/32  trust" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host all all $IP_Adminer/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host all all $IP_PgAdmin/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host all all $IP_host_docker/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "" | sudo tee -a $path_Postgres/pg_hba.conf

    echo "== В файле 'pg_hba.conf': =="
    sudo cat $path_Postgres/pg_hba.conf |grep "host "

    docker restart $Container_Postgres_name

    #--------------------------------------------------
    # Закрыть доступ к СУБД Postgres через IPTABLES 
    pass

fi

#============================================
echo 
read -p "=== Ограничить доступ к PgAdmin-у и Adminer-у только во время подключения по SSH? [y/N]: " restrict_tools
if [ "$restrict_tools" == "y" ]; then  
#    wget -O ~/.tools_start.sh https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/master/.tools_start.sh
#    wget -O ~/.tools_stop.sh https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/master/.tools_stop.sh
    cp -R ~/PostgreSQL_VPS/.tools_start.sh ~/
    cp -R ~/PostgreSQL_VPS/.tools_stop.sh ~/
    
    echo "if [ -f ~/.tools_start.sh ]; then" >> ~/.bashrc
    echo "    . ~/.tools_start.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc

    echo "if [ -f ~/.tools_stop.sh ]; then" >> ~/.bash_logout
    echo "    . ~/.tools_stop.sh" >> ~/.bash_logout
    echo "fi" >> ~/.bash_logout 

    #--------------------------------------------------
    echo 
    read -p "=== Ограничить доступ к PgAdmin-у и Adminer-у только по вашему IP адресу подключения? [y/N]: " restrict_IP
    if [ "$restrict_IP" == "y" ]; then  
        # Ограничить по IP для PgAdmin и Adminer через IPTABLES    
        pass
    fi
fi

#============================================
#wget http://ipecho.net/plain -O - -q
#curl http://icanhazip.com
#curl http://ifconfig.me/ip
#============================================
#IP_Postgres=`docker exec $Container_Postgres_name hostname -i`
#IP_PgAdmin=`docker exec $Container_PgAdmin_name hostname -i`
#IP_Adminer=`docker exec $Container_Adminer_name hostname -i`
#============================================
#openssl req -newkey rsa:2048 -sha256 -nodes -keyout 94.241.139.33.self.key -x509 -days 365 -out 94.241.139.33.self.crt -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=94.241.139.33"
#============================================
#wget -q -4 -O- http://icanhazip.com
#============================================
#Port_PgAdmin=`docker inspect -f '{{range.HostConfig.PortBindings}}{{.HostPort}}{{end}}' $Container_PgAdmin_name` -не работает
#port_pg="$(docker compose port pgadmin 443)"  => 0.0.0.0:55050  - рабочий
#echo "${port_pg##*:}"   =>  55050
#docker ps -q | xargs -n1 docker port |grep 55050
#============================================
#============================================
#============================================
#if [ -f ~/.tools ]; then
#    . ~/.tools
#fi
#    echo "./tools_stop.sh" >> ~/.bash_logout
#    echo "./tools_start.sh" >> ~/.bashrc
#============= Поменять пароль в докере ======================
#docker exec  postgres_cont su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'pass1';\""
#=============================================================
#=============================================================
#path_Postgres='./'
#sudo psql -U postgres -h 172.18.0.3 -p 5432 -d postgres -W

#echo "host  all  all  127.0.0.1/32  trust" >> $path_Postgres/pg_hba.conf
#echo "host  replication all 127.0.0.1/32  trust" >> $path_Postgres/pg_hba.conf
#echo "host all all $IP_Adminer/32 scram-sha-256" >> $path_Postgres/pg_hba.conf
#echo "host all all $IP_PgAdmin/32 scram-sha-256" >> $path_Postgres/pg_hba.conf
#echo "host all all $IP_host_docker/32 scram-sha-256" >> $p
#sudo ls -al $path_Postgres/postgresql*
#sed -i -e "/=====/d" $path_Postgres/postgresql.conf


#ip_addr=>  docker inspect   -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres_cont 

#sed -i '/pattern/d' file
#sed -i -e "s/$var1/$var2/g" /tmp/file.txt


#if [ "$docker_postgres_state" == "Up"]
#if [ "$(docker ps -q -f name=$docker_Adminer_name -f status=running)" ]; then
#    docker container stop $docker_Adminer_name
#    echo "Контейнер $docker_Adminer_name остановлен"
#fi
#if [ "$(docker ps -q -f name=$docker_Adminer_name -f status=exited)" ]; then
#    docker container start $docker_Adminer_name
#    echo "Контейнер $docker_Adminer_name запущен!!!"
#fi


#============================================================
#docker ps -q -f name=cont -f status=exited  #=> 3768e655a275
#docker ps -q -f name=cont -f status=running #=> 9c86e256942d
                                               # 8a420db3e341
#docker exec adminer_cont hostname -i  #=> 172.18.0.4
#docker exec pgadmin_cont hostname -i #=> 172.18.0.3
#docker exec postgres_cont hostname -i #=> 172.18.0.2

#SSH_CLIENT=178.205.48.250 60613 22
#SSH_CONNECTION=178.205.48.250 60613 94.241.139.33 22
#IP_user=`echo $SSH_CLIENT | awk '{print $5}' `
#IP_user=`echo $SSH_CLIENT | cut -d " " -f1`



#----------------------
#=====================================
#IP_user=`who a mi| cut -d"(" -f2 |cut -d")" -f1`
#docker_postgres_name=`docker ps -a |grep 5432 |awk {'print $12'}`
#docker_postgres_id=`docker ps -aqf "name=postgres"`
#docker_postgres_state=`docker ps -a |grep 5432 |awk {'print $7'}`
#---------------------------------
#if [ ! "$(docker ps -a -q -f name=<name>)" ]
# then
#    if [ "$(docker ps -aq -f status=exited -f name=<name>)" ]; then
#        # cleanup
#        docker rm <name>
#    fi
#    # run your container
#    docker run -d --name <name> my-docker-image
#fi
#============================
#CNAME=$CONTAINER_NAME-$CODE_VERSION
#if [ "$(docker ps -qa -f name=$CNAME)" ]; then
#    echo ":: Found container - $CNAME"
#    if [ "$(docker ps -q -f name=$CNAME)" ]; then
#        echo ":: Stopping running container - $CNAME"
#        docker stop $CNAME;
#    fi
#    echo ":: Removing stopped container - $CNAME"
#    docker rm $CNAME;
#fi
#============================================================
# === Смена пароля root-а ===

#echo 
#read -p "=== Сменить у пользователя 'root' пароль? [y/N]: " change_passwd_root
#
#if [ "$change_passwd_root" == "y" ]
#then
#    passwd root
#fi

