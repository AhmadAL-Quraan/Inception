COMPOSE_FILE=docker compose -f srcs/docker-compose.yml
include srcs/.env
export

USER_DATA:= $(DATA_PATH)

all: up

up: 
	@mkdir -p $(USER_DATA)/wordpress/
	@mkdir -p $(USER_DATA)/mariadb/
	$(COMPOSE_FILE) up  --build -d 
	@echo 
	@echo "Finished"
	@echo "Visit my website on: https://aqoraan.42.fr"


down:
	$(COMPOSE_FILE) down

stop:
	$(COMPOSE_FILE) stop

start:
	$(COMPOSE_FILE) start

restart: down up

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(USER_DATA)/mariadb/*
	sudo rm -rf $(USER_DATA)/wordpress/*


re: fclean all


.PHONY: all stop start fclean re clean restart up down


