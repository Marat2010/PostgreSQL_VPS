## PostgreSQL, PgAdmin, Adminer, Docker compose, VPS 

### Описание
Установка PostgreSQL & PgAdmin & Adminer через docker compose на **VPS/VDS**.  

  Подключаемся к серверу **`ssh root@xxx.xxx.xxx.xxx (_IP_Addr_)`**.    

1. Выполним команду:  
    ```
    wget -O ./1_postgres.sh https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/master/1_postgres.sh && chmod +x 1_postgres.sh && ./1_postgres.sh
    ```

    Команда скопирует скрипт, сделает его исполняемым и запустит.  

    Действия скрипта:  

    - Смена пароля "root-а"  
    - Настройка, создание пользователя или ввод существующего.  
    - Установка пакетов: **docker, docker-compose**  
    - Копирование **'docker-compose.yml'**  
    - Задает имя пользователя БД (по умолчанию **postgres**)  
    - Задает пароль к БД (по умолчанию **changeme**)  
    - Запуск контейнеров: **postgres, adminer, pgadmin**  
    - Данные для подключения к БД для **adminer** и **pgadmin**  

Тестировался на ОС: Ubuntu 20.04, Ubuntu 22.04 (Timeweb, Рег.ру)
<hr>

Проверка подключения:  
* PgAdmin по адресу: `http://_IP_Addr_:`**`5050`**  
* Adminer по адресу: `http://_IP_Addr_:`**`8080`**  

<hr>
2. Для обеспечения бьезопасности необходимо запустить второй скрипт:  
    ```
    wget -O ./1_postgres.sh https://raw.githubusercontent.com/Marat2010/PostgreSQL_VPS/secure/2_secure.sh && chmod +x 2_secure.sh && ./2_secure.sh
    ```

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

