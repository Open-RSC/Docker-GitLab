#!/bin/bash
# Basic software
echo ""
echo ""
echo "Installing Certbot, Screen, Tmux, Zip, Fail2Ban, Unzip, Git, Build-Essential, Software-Properties-Common, APT-Transport-HTTPS, CA-Certificates, Curl, and configuring the system timezone."
echo ""
sudo apt update && sudo make apt upgrade -y && sudo apt autoremove -y
sudo apt install git htop nano tmux unzip zip fail2ban git build-essential apt-transport-https ca-certificates software-properties-common curl screen ack certbot gtk3-nocsd openssh-server -y
sudo dpkg-reconfigure tzdata

# UFW Firewall configuration
echo ""
echo ""
echo "Setting Ubuntu Firewall permissions."
echo ""
sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw allow 22/tcp && sudo ufw allow 55555/tcp
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DENY"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw

sudo ufw reload
sudo ufw --force enable

# Configures and secures SSH access
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 720/g' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 720/g' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries/MaxAuthTries/g' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
sudo sed -i 's/#Port 22/Port 55555/g' /etc/ssh/sshd_config
sudo service ssh restart
systemctl restart sshd

# Configures Fail2Ban
sudo echo '[sshd] 
            enabled = true
            banaction = iptables-multiport
            maxretry = 10
            findtime = 43200
            bantime = 86400

            [sshlongterm]
            port      = ssh
            logpath   = %(sshd_log)s
            banaction = iptables-multiport
            maxretry  = 35
            findtime  = 259200
            bantime   = 608400
            enabled   = true
            filter    = sshd' | sudo tee /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

# Installs Docker Community Edition
sudo apt-get update && sudo apt-get install -y \
  linux-image-extra-"$(uname -r)" \
  linux-image-extra-virtual
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
sudo apt install docker docker-compose -y
# Adds instance user to docker group so it can execute commands.
sudo usermod -a -G docker ubuntu
# Permits instance user to execute Docker commands without sudo
sudo setfacl -m user:"$USER":rw /var/run/docker.sock
# 4.5  - Ensures Content trust for Docker is Enabled
echo "DOCKER_CONTENT_TRUST=1" | sudo tee -a /etc/environment
echo "DOCKER_OPTS="--iptables=false" | sudo tee -a /etc/default/docker"
# Config to implement changes for 2.1 - 2.15
sudo mv /tmp/daemon.json /etc/docker/daemon.json
echo ""
echo "Setting Docker to have the correct storage driver and restarting the service."
echo '{
            "storage-driver": "overlay2"
            }' | sudo tee /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
sudo service docker restart
sudo docker network create nginx-proxy
