# User documentation

## Services provided

| Service   | Role                                         | Reachable from         |
|-----------|----------------------------------------------|------------------------|
| nginx     | HTTPS entry point (port 443, TLSv1.2/1.3)    | https://nguinot-.42.fr |
| wordpress | WordPress website run by php-fpm (port 9000) | nginx only             |
| mariadb   | WordPress database (port 3306)               | wordpress only         |

## Start and stop the project

From the root of the repository:

    make          # build and start everything
    make stop     # pause the containers
    make start    # resume them
    make down     # stop and remove the containers (data is kept)

## Access the website and the administration panel

- Website: https://nguinot-.42.fr (accept the self-signed certificate warning)
- Administration panel: https://nguinot-.42.fr/wp-admin

## Locate and manage credentials

- User names are in `srcs/.env` (`WP_ADMIN_USER`, `WP_USER`, `MYSQL_USER`).
- Passwords are in `secrets/`: `credentials.txt` (WordPress accounts),
  `db_password.txt` (WordPress database user), `db_root_password.txt`
  (MariaDB root).
- These files are not in Git. Keep a private copy.
- To change a WordPress password, update `secrets/credentials.txt`, then run:

      docker exec wordpress wp user update <user> --user_pass='<new>' --allow-root

## Check that the services are running

    make ps                           # 3 containers "Up", mariadb "(healthy)"
    make logs                         # live logs of all services
    curl -k https://nguinot-.42.fr    # returns the HTML of the website
