#!/bin/bash
#Copyright (c) 2023 Woshishee

# Check if UUID environment variable is set
if [ -z "$UUID" ]; then
    echo "Please set the UUID environment variable."
    exit 1
fi

# Set env.
export api_file=/app/api.cfg

# Check internet access.
echo -e "GET http://peer.proxyrack.com HTTP/1.0\n\n" | nc peer.proxyrack.com 443 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Welcome to Proxyrack!"
else
    echo "Please check your internet connection and try again."
fi

function start_proxyrack() {
	echo "Updating Proxyrack..."
	rm -rf script.js
	wget https://app-updates.sock.sh/peerclient/script/script.js
	echo "Update done!"
	node script.js --homeIp point-of-presence.sock.sh --homePort 443 --id $UUID --version $(curl --silent https://app-updates.sock.sh/peerclient/script/version.txt) --clientKey proxyrack-pop-client --clientType PoP 
}

function add_device() {
	echo "Adding device to dashboard..."
	sleep 2m
	curl -X POST https://peer.proxyrack.com/api/device/add -H "Api-Key: ${api_key}" -H 'Content-Type: application/json' -H 'Accept: application/json' -d '{"device_id":"'"$UUID"'","device_name":"'"$device_name"'"}'
}

echo "Using provided UUID: $UUID"
start_proxyrack &

while true; do sleep 1; done
