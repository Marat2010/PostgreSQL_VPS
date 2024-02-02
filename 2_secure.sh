#!/bin/bash

docker_Adminer_name="adminer_cont"
docker_PgAdmin_name="pgadmin_cont"
docker_Postgres_name="postgres_cont"

ip_user=`who am i --ips|awk '{print $5}'`
docker_network=`docker network ls |grep net_postgres |awk '{print $2}'`
ip_host_docker=`docker inspect -f '{{range.IPAM.Config}}{{.Gateway}}{{end}}' $docker_network`
ip_Adminer=`docker exec $docker_Adminer_name hostname -i`
ip_PgAdmin=`docker exec $docker_PgAdmin_name hostname -i`
ip_Postgres=`docker exec $docker_Postgres_name hostname -i`

echo "IP Адрес пользователя: $ip_user"
echo "IP Адрес Adminer-a: $ip_Adminer"
echo "IP Адрес PgAdmin-a: $ip_PgAdmin"
echo "IP Адрес Postgres-a: $ip_Postgres"

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

    docker exec  postgres_cont su - $POSTGRES_USER -c "psql -U $POSTGRES_USER -d $POSTGRES_USER -c \"alter user $POSTGRES_USER with password '$POSTGRES_PASSWORD';\""
    echo "== Пользователь БД: $POSTGRES_USER , пароль: $POSTGRES_PASSWORD =="
fi

#============================================
echo 
read -p "=== Закрыть доступ к БД из интернета? [y/N]: " close_external_access
if [ "$close_external_access" == "y" ]; then  
    #------------ Редактирование postgresql.conf -----------------------------------
    path_Postgres='/var/lib/docker/volumes/postgresql_vps_postgres/_data'

    sudo cp $path_Postgres/postgresql.conf $path_Postgres/postgresql.conf_all.bak

    listen_addresses_old="listen_addresses = '\*'"
    listen_addresses_new="listen_addresses = '$ip_Postgres'"

    sudo sed -i -e "s/$listen_addresses_old/$listen_addresses_new/g" $path_Postgres/postgresql.conf

    echo "== В файле 'postgresql.conf' listen_addresses: =="
    sudo cat $path_Postgres/postgresql.conf |grep listen

    #------------ Редактирование pg_hba.conf -----------------------------------
    sudo cp $path_Postgres/pg_hba.conf $path_Postgres/pg_hba.conf_all.bak

    sudo sed -i -e "s/host /#host /g" $path_Postgres/pg_hba.conf

    echo "host  all  all  127.0.0.1/32  trust" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host  replication all 127.0.0.1/32  trust" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host all all $ip_Adminer/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "host all all $ip_PgAdmin/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
#    echo "host all all $ip_host_docker/32 scram-sha-256" | sudo tee -a $path_Postgres/pg_hba.conf
    echo "" | sudo tee -a $path_Postgres/pg_hba.conf

    echo "== В файле 'pg_hba.conf': =="
    sudo cat $path_Postgres/pg_hba.conf |grep "host "

    docker restart $docker_Postgres_name

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
fi

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
#echo "host all all $ip_Adminer/32 scram-sha-256" >> $path_Postgres/pg_hba.conf
#echo "host all all $ip_PgAdmin/32 scram-sha-256" >> $path_Postgres/pg_hba.conf
#echo "host all all $ip_host_docker/32 scram-sha-256" >> $p
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
#ip_user=`echo $SSH_CLIENT | awk '{print $5}' `
#ip_user=`echo $SSH_CLIENT | cut -d " " -f1`



#----------------------
#=====================================
#ip_user=`who a mi| cut -d"(" -f2 |cut -d")" -f1`
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

