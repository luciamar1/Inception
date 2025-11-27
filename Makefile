# Variables
COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

clean: down
	$(COMPOSE) down -v
	docker system prune -f

fclean: clean
	docker system prune -af --volumes
	docker volume rm -f inception_mariadb_data inception_wordpress_data 2>/dev/null || true

re: fclean all

logs:
	$(COMPOSE) logs -f

status:
	docker ps

.PHONY: all up down stop clean fclean re logs status
