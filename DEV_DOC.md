# Developer documentation

## Set up the environment from scratch

Prerequisites: a Linux VM (Debian 13 here) with Docker Engine, the Docker
Compose plugin, `git` and `make`, and your user in the `docker` group.

    echo "127.0.0.1 nguinot-.42.fr" | sudo tee -a /etc/hosts
    git clone <repository> inception && cd inception

Create `srcs/.env`:

    DOMAIN_NAME=nguinot-.42.fr
    MYSQL_DATABASE=wordpress
    MYSQL_USER=wpuser
    WP_TITLE=Inception
    WP_ADMIN_USER=wpboss
    WP_ADMIN_EMAIL=wpboss@example.com
    WP_USER=wpauthor
    WP_USER_EMAIL=wpauthor@example.com

Create the secrets (letters and digits only):

    mkdir -p secrets
    openssl rand -hex 16 > secrets/db_root_password.txt
    openssl rand -hex 16 > secrets/db_password.txt
    printf 'WP_ADMIN_PASSWORD=%s\nWP_USER_PASSWORD=%s\n' \
        "$(openssl rand -hex 16)" "$(openssl rand -hex 16)" > secrets/credentials.txt

## Build and launch

    make      # checks the private files, creates /home/nguinot-/data/*,
              # builds the 3 images and starts the stack
    make re   # full rebuild from scratch (deletes the data)

The Makefile runs `docker compose -f srcs/docker-compose.yml up -d --build`.

## Manage containers and volumes

    docker compose -f srcs/docker-compose.yml ps
    docker logs <mariadb|wordpress|nginx>
    docker exec -it <container> bash
    docker exec -it mariadb mariadb -u root -p
    docker exec wordpress wp user list --allow-root
    docker volume ls
    docker volume inspect inception_mariadb
    docker network inspect inception

## Where the data is stored and how it persists

| Volume              | Path in the container | Path on the VM                |
|---------------------|-----------------------|-------------------------------|
| inception_mariadb   | /var/lib/mysql        | /home/nguinot-/data/mariadb   |
| inception_wordpress | /var/www/html         | /home/nguinot-/data/wordpress |

The data survives `make down`, `make clean` and reboots, because it lives on
the VM's disk. The startup scripts only initialise the database and WordPress
when this data is missing. Only `make fclean` deletes it.
