## Postgresql, PgAdmin, Adminer, Docker compose, VPS 

### Описание
Установка Postgresql & PgAdmin & Adminer через docker compose на VPS/VDS.  
Проверено на ОС серверов Timeweb, Рег.ру:  Ubuntu 20.04, Ubuntu 22.04.

  Подключаемся к серверу **`ssh root@xxx.xxx.xxx.xxx (_IP_Addr_)`** и выполняем последовательно команды.    

1. Выполним команду:  
    ```
    wget -O ./1_postgres.sh https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/master/1_postgres.sh 
&& chmod +x 1_postgres.sh 
&& ./1_postgres.sh
    ```
Команда скопирует скрипт, сделает его исполняемым и запустит.  

Действия скрипта:

    - Смена пароля "root-а"
    - Настройка, создание пользователя или ввод существующего.
    - Установка пакетов: **docker, docker-compose**
    - Копирование **'docker-compose.yml'** в каталог пользователя
    - Задает имя пользователя БД (по умолчанию **postgres**)
    - Задает пароль пользователя БД (по умолчанию **changeme**)
    - Установка и запуск контейнеров: **postgres, adminer, pgadmin**
    - Формирует данные для подключения к БД для **adminer, pgadmin**

<hr>

Проверка:  
* PgAdmin по адресу: `http://_IP_Addr_:`**`5050`**  
* Adminer по адресу: `http://_IP_Addr_:`**`8080`**  

<hr>

Сделано на базе <a href='https://github.com/khezen/compose-postgres'>Compose-postgres</a> + добавлен <a href='https://hub.docker.com/_/adminer'>Adminer</a>

### Environments
This Compose file contains the following environment variables:

* `POSTGRES_USER` the default value is **postgres**
* `POSTGRES_PASSWORD` the default value is **changeme**
* `PGADMIN_PORT` the default value is **5050**
* `PGADMIN_DEFAULT_EMAIL` the default value is **pgadmin4@pgadmin.org**
* `PGADMIN_DEFAULT_PASSWORD` the default value is **admin**

### Access to postgres: 
* **Host name/address:port:** `_IP_Addr_:5432`
* **Username:** `postgres` (as a default)
* **Password:** `changeme` (as a default)

### Access to PgAdmin: 
* **URL:** `http://_IP_Addr_:5050`
* **Username:** pgadmin4@pgadmin.org (as a default)
* **Password:** `admin` (as a default)

### Add a new server in PgAdmin:
* **Host name/address** `_IP_Addr_`
* **Port** `5432`
* **Username** as `POSTGRES_USER`, by default: `postgres`
* **Password** as `POSTGRES_PASSWORD`, by default `changeme`

### Access to Adminer: 
* **URL:** `http://_IP_Addr_:8080`
* **System:** `PostgreSQL`
* **Server:** `_IP_Addr_`
* **Username** as `POSTGRES_USER`, by default: `postgres`
* **Password** as `POSTGRES_PASSWORD`, by default `changeme`
<hr>

