install:
	`pwd`/scripts/install.sh

ufw-import:
	`pwd`/scripts/ufw-import.sh

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

restore:
	sudo docker exec -it gitlab gitlab-rake gitlab:backup:restore
	# Tar must be located in /srv/gitlab/backups to be found