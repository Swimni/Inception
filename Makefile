LOGIN    = nguinot-
DATA_DIR = /home/$(LOGIN)/data
COMPOSE  = docker compose -f srcs/docker-compose.yml
REQUIRED = srcs/.env secrets/db_root_password.txt secrets/db_password.txt secrets/credentials.txt

all: up

up: check
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

check:
	@for f in $(REQUIRED); do \
	    if [ ! -f $$f ]; then echo "Missing file: $$f"; exit 1; fi; \
	done

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	sudo rm -rf $(DATA_DIR)
	docker system prune -af

re: fclean all

.PHONY: all up check down start stop ps logs clean fclean re
