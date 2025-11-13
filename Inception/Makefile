# Variables
COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_PATH = /home/lucia/data

all: up

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

clean: down
	$(COMPOSE) down -v
	docker system prune -f

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker system prune -af --volumes

re: fclean all

dirs:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

logs:
	$(COMPOSE) logs -f

status:
	docker ps

.PHONY: all up down stop clean fclean re dirs logs status
