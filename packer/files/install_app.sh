#!/bin/sh

git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

sudo bash -c 'echo "[Unit] 
Description=Reddit-App 
After=network.target 

[Service] 
Type=simple
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma -b tcp://0.0.0.0:9292
Restart=always
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/puma-service.service'

sudo systemctl daemon-reload
sudo systemctl enable puma-service
sudo systemctl start puma-service