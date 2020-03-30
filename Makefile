update:
	@docker-compose down -v
	sudo docker image rm gitlab/gitlab-ce
	docker-compose up -d

ufw-import:
	cd scripts && `pwd`/ufw-import.sh

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
	sudo docker exec -it gitlab gitlab-ctl stop unicorn
	sudo docker exec -it gitlab gitlab-ctl stop puma
	sudo docker exec -it gitlab gitlab-ctl stop sidekiq
	sudo docker exec -it gitlab gitlab-backup restore BACKUP=${name}
	# Tar must be located in /srv/gitlab/backups to be found

reconfigure:
	sudo docker exec -it gitlab gitlab-ctl reconfigure

full-refresh:
	sudo docker exec -it gitlab gitlab-ctl reconfigure && sudo sudo docker exec -it gitlab gitlab-rake gitlab:check SANITIZE=true && sudo docker exec -it gitlab gitlab-ctl restart