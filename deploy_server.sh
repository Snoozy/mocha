#!/bin/bash

server_ips="54.203.8.127"

for server in "$server_ips"
do
    echo "Deploying to ${server}..."
    ssh ubuntu@${server} bash -c "'
        rm -rf server-bak/
        cp -R server/ server-bak/
    '"
    rsync -avzq --exclude 'config' server/ ubuntu@${server}:~/server
    rsync -avzq --no-R --no-implied-dirs ~/.marble/config.prod ubuntu@${server}:~/server/config
    ssh ubuntu@${server} bash -c "'
        cd server/
        sudo pip3 install -r requirements.txt
        kill \$(cat marble.pid)
        ./prod_run_server.sh
    '"
done
