COMPOSE_FILE=docker compose -f srcs/docker-compose.yml

USER:=$(shell whoami)

all: up

up: 
	@mkdir -p /home/$(USER)/data/wordpress/
	@mkdir -p /home/$(USER)/data/mariadb/
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
	sudo rm -rf /home/$(USER)/data/mariadb/*
	sudo rm -rf /home/$(USER)/data/wordpress/*


re: fclean all


.PHONY: all stop start fclean re clean restart up down


