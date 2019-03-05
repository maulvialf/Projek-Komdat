#!/bin/bash

# install dependency

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update upgrade -y
sudo apt-get install -y nodejs mongodb-org git
sudo systemctl stop apache2.service
sudo systemctl start mongod

# create db

# read -sp 'Admin Passwd: ' adminpasswd
# read -sp 'Nodebb Passwd: ' nodebbpasswd

echo '
use admin
db.createUser( { user: "admin", pwd: "admin", roles: [ { role: "root", db: "admin" } ] } )
use nodebb
db.createUser( { user: "nodebb", pwd: "nodebb", roles: [ { role: "readWrite", db: "nodebb" }, { role: "clusterMonitor", db: "admin" } ] } )
quit()
' | mongo

# enable in bash
# security:
#   authorization: enabled
sudo systemctl restart mongod
mongo -u admin -p your_password --authenticationDatabase=admin
git clone -b v1.11.x https://github.com/NodeBB/NodeBB.git nodebb
cd nodebb
./nodebb setup
./nodebb start

cd /etc/nginx/sites-available
sudo nano forum.example.com # config entered into file and saved
cd ../sites-enabled
sudo ln -s ../sites-available/forum.example.com

# server {
#     listen 80;

#     server_name forum.example.com;

#     location / {
#         proxy_set_header X-Real-IP $remote_addr;
#         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto $scheme;
#         proxy_set_header Host $http_host;
#         proxy_set_header X-NginX-Proxy true;

#         proxy_pass http://127.0.0.1:4567;
#         proxy_redirect off;

#         # Socket.IO Support
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
#     }
# }

sudo systemctl reload nginx