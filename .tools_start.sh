#!/bin/bash

ip_user=`who am i --ips|awk '{print $5}'`
echo "IP Адрес пользователя: $ip_user"
#ip_Adminer=`docker exec adminer_cont hostname -i`
#echo "IP Адрес Adminer-a: $ip_Adminer"

Container_PgAdmin_name="pgadmin_cont"
Container_Adminer_name="adminer_cont"

if [ "$(docker ps -q -f name=$Container_Adminer_name -f status=exited)" ]; then
    docker container start $Container_Adminer_name
    echo "Контейнер $Container_Adminer_name запущен!!!"
fi

if [ "$(docker ps -q -f name=$Container_PgAdmin_name -f status=exited)" ]; then
    docker container start $Container_PgAdmin_name
    echo "Контейнер $Container_PgAdmin_name запущен!!!"
fi





