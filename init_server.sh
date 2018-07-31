#!/bin/bash

server_ips="54.70.80.131"

for server in "$server_ips"
do
    echo "Deploying to ${server}"
    ssh ubuntu@${server} bash -c "'
        rm -rf server-bak/
        cp -R server/ server-bak/
    '"
    rsync -avzq --exclude 'config' server/ ubuntu@${server}:~/server
    rsync -avzq --no-R --no-implied-dirs ~/.marble/config.prod ubuntu@${server}:~/server/config
    ssh ubuntu@${server} bash -c "'
        sudo apt-get update
        sudo apt-get install python3-pip libpq-dev python3.6-dev -y
        python3.6 -m venv mvenv
        . mvenv/bin/activate
        cd server/
        pip install -r requirements.txt > /dev/null
        kill \$(cat ~/server-bak/marble.pid)
        ./prod_run_server.sh
    '"
done
echo "Done deploying"
