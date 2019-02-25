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