sudo apt-get update
sudo apt-get install curl
sudo curl -fsSl https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu
sudo docker --version  #checks docker version. 


#docker-compose installation


sudo curl -L https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-windows-x86_64.exe -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo docker-compose --version
