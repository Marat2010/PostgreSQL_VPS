## Postgresql, PgAdmin, Adminer, Docker compose, VPS 

### Описание
Установка Postgresql & PgAdmin & Adminer через docker compose на VPS/VDS.  
Проверено на ОС серверов Timeweb, Рег.ру:  Ubuntu 20.04, Ubuntu 22.04.

1. Подключаемся к серверу `ssh root@xxx.xxx.xxx.xxx (_IP_Addr_)` и выполняем последовательно команды.    

2. Скачиваем первый скрипт, выполним команду:  
    ```
    wget https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/master/1_postgres.sh
    ```

3. Делаем скрипт исполняемым:  
   ```
   chmod +x 1_postgres.sh
    ```

4. Запускаем скрипт (под root-ом):  
    ```
    ./1_postgres.sh
    ```

    - Смена пароля "root"
    - Создание пользователя.
    - Установка пакетов: docker, docker-compose
    - Копирование 'docker-compose.yml' в каталог пользователя
    - Установка и запуск контейнеров: postgres, adminer, pgadmin

<hr>

Проверка:  
* PgAdmin по адресу: `http://_IP_Addr_:**55050**`  
* Adminer по адресу: `http://_IP_Addr_:`**`58080`**  

<hr>

Сделано на базе <a href='https://github.com/khezen/compose-postgres'>Compose-postgres</a> + добавлен <a href='https://hub.docker.com/_/adminer'>Adminer</a>

## Environments
This Compose file contains the following environment variables:

* `POSTGRES_USER` the default value is **postgres**
* `POSTGRES_PASSWORD` the default value is **changeme**
* `PGADMIN_PORT` the default value is **55050**
* `PGADMIN_DEFAULT_EMAIL` the default value is **pgadmin4@pgadmin.org**
* `PGADMIN_DEFAULT_PASSWORD` the default value is **admin**

## Access to postgres: 
* **Host name/address:port:** `_IP_Addr_:5432`
* **Username:** postgres (as a default)
* **Password:** changeme (as a default)

## Access to PgAdmin: 
* **URL:** `http://_IP_Addr_:55050`
* **Username:** pgadmin4@pgadmin.org (as a default)
* **Password:** admin (as a default)

## Add a new server in PgAdmin:
* **Host name/address** `_IP_Addr_`
* **Port** `5432`
* **Username** as `POSTGRES_USER`, by default: `postgres`
* **Password** as `POSTGRES_PASSWORD`, by default `changeme`

## Access to Adminer: 
* **URL:** `http://_IP_Addr_:58080`
* **System:** `PostgreSQL`
* **Server:** `_IP_Addr_`
* **Username:** postgres (as a default)
* **Password:** changeme (as a default)
<hr>

