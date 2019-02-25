install:
	`pwd`/scripts/install.sh

logs:
	@docker-compose logs -f

start:
	docker-compose up -d

stop:
	@docker-compose down -v

restart:
	@docker-compose down -v
	docker-compose up -d

ps:
	docker-compose ps

backup:
	sudo docker exec -t gitlab gitlab-rake gitlab:backup:create
	# Automate this with sudo contab -e
	# 0 2 * * * docker exec -t gitlab gitlab-rake gitlab:backup:create CRON=1