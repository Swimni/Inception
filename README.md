*This project has been created as part of the 42 curriculum by nguinot-.*

# Inception

## Description

Inception sets up a small web infrastructure with Docker Compose inside a
virtual machine: an NGINX server (TLS only), a WordPress site run by php-fpm,
and a MariaDB database. Each service runs in its own container, built from my
own Dockerfile on Debian 12 (bookworm).

### Use of Docker and project sources

- `srcs/docker-compose.yml` describes the 3 services, the `inception` bridge
  network, 2 named volumes and 3 Docker secrets.
- `srcs/requirements/<service>/` holds one Dockerfile per service, its
  configuration file (`conf/`) and its startup script (`tools/`).
- `Makefile` creates the data folders, then builds and starts the stack.

### Main design choices

- Debian 12 "bookworm" base images, the penultimate stable Debian release.
- NGINX is the only entry point (port 443, TLSv1.2/TLSv1.3, self-signed
  certificate). It serves static files and passes PHP to php-fpm (FastCGI).
- Every container runs its main process in the foreground as PID 1 (`exec`),
  with no infinite loop.
- Non-sensitive settings live in `srcs/.env`, passwords in Docker secrets
  (`secrets/`). Both are ignored by Git.
- Startup scripts only initialise the database and WordPress on first run,
  so a restart never overwrites existing data.

### Virtual Machines vs Docker

A virtual machine emulates a whole computer with its own kernel on top of a
hypervisor: it weighs gigabytes and boots in tens of seconds. A container
shares the host kernel and isolates processes with namespaces and cgroups: it
weighs megabytes and starts in about a second. A VM isolates more strongly;
containers are lighter and reproducible from a Dockerfile. This project uses
both: Docker runs inside a VM.

### Secrets vs Environment Variables

Environment variables are visible to every process in the container and in
`docker inspect`: fine for non-sensitive settings such as the domain name or
user names. Docker secrets are files mounted read-only in `/run/secrets/`,
only in the containers that declare them; they are not stored in the image
and do not show in `docker inspect`. All passwords here are secrets.

### Docker Network vs Host Network

With the host network, a container shares the host's network stack: every
port it opens is opened on the host, with no isolation. A user-defined bridge
network gives the containers a private network with internal DNS (they reach
each other by service name) and exposes only the ports published explicitly.
Here only NGINX publishes a port: 443.

### Docker Volumes vs Bind Mounts

A bind mount maps a host path into a container and depends on the host's
directory layout. A named volume is an object managed by Docker: it is
created, listed, inspected and removed with `docker volume`, and shared
between services by name. Here both named volumes use the local driver and
store their data in `/home/nguinot-/data`.

## Instructions

Requirements: a Linux VM with Docker Engine, the Docker Compose plugin and
`make`, and `nguinot-.42.fr` mapped to `127.0.0.1` in `/etc/hosts`.

1. Create `srcs/.env` and the 3 files in `secrets/` (see DEV_DOC.md).
2. Run `make`.
3. Open https://nguinot-.42.fr and accept the self-signed certificate.

`make down` stops the stack and `make fclean` removes everything, data
included. See USER_DOC.md and DEV_DOC.md for details.

## Resources

- Docker documentation: https://docs.docker.com/
- Compose file reference: https://docs.docker.com/reference/compose-file/
- Dockerfile best practices: https://docs.docker.com/build/building/best-practices/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/docs/
- WP-CLI: https://wp-cli.org/
- PHP-FPM configuration: https://www.php.net/manual/en/install.fpm.configuration.php

### AI usage

Claude was used to get a step-by-step guide of the project (VM setup,
Dockerfiles, scripts, configuration files) with explanations of each block,
and to debug setup issues (DNS of the VM, SSH keys, sudo). I typed, tested
and adapted every file myself and checked the explanations against the
official documentation.
