# Postgresql & PgAdmin & Adminer & docker compose & VPS

## Установка Postgresql & PgAdmin & Adminer через docker compose на VPS 

### Описание
Установка Postgresql & PgAdmin & Adminer через docker compose на VPS/VDS.  
Проверено на ОС серверов Timeweb, Рег.ру:  Ubuntu 20.04, Ubuntu 22.04.

1. Подключаемся к серверу `ssh root@xxx.xxx.xxx.xxx` и выполняем последовательно команды.    

2. Скачиваем первый скрипт, выполним команду:  
    ```
    wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/Scripts/1_start.sh
    ```

3. Делаем скрипт исполняемым:  
   ```
   chmod +x 1_start.sh
    ```

4. Запускаем скрипт (под root-ом):  
    ```
    ./1_start.sh
    ```
   
    - Смена пароля "root"
    - Создание пользователя.
    - Установка пакетов: docker, docker-compose
    - Копирование 'docker-compose.yml' в каталог пользователя
    - Установка и запуск контейнеров: postgres, adminer, pgadmin

<hr>

Сделано на базе <a href='https://github.com/khezen/compose-postgres'>Compose-postgres</a>

## Environments
This Compose file contains the following environment variables:

* `POSTGRES_USER` the default value is **postgres**
* `POSTGRES_PASSWORD` the default value is **changeme**
* `PGADMIN_PORT` the default value is **5050**
* `PGADMIN_DEFAULT_EMAIL` the default value is **pgadmin4@pgadmin.org**
* `PGADMIN_DEFAULT_PASSWORD` the default value is **admin**

## Access to postgres: 
* `localhost:5432`
* **Username:** postgres (as a default)
* **Password:** changeme (as a default)

## Access to PgAdmin: 
* **URL:** `http://localhost:5050`
* **Username:** pgadmin4@pgadmin.org (as a default)
* **Password:** admin (as a default)

## Add a new server in PgAdmin:
* **Host name/address** `postgres`
* **Port** `5432`
* **Username** as `POSTGRES_USER`, by default: `postgres`
* **Password** as `POSTGRES_PASSWORD`, by default `changeme`

## Logging

There are no easy way to configure pgadmin log verbosity and it can be overwhelming at times. It is possible to disable pgadmin logging on the container level.

Add the following to `pgadmin` service in the `docker-compose.yml`:

```
logging:
  driver: "none"
```

[reference](https://github.com/khezen/compose-postgres/pull/23/files)
