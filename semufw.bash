#!/bin/bash

# This is NOT production-ready script.
# It's an idea on how to automate updating of UFW rules on ips-S2.txt changes.
# Use cron to run the file daily or as needed. Pipe the output to the log.

# Name of the file to track.
semfile="ips-S2.txt"
# URL of the file to track.
semipurl="https://raw.githubusercontent.com/renderedtext/snippets/master/ips-S2.txt"
# Path to the local file.
path="/home/ubuntu/${semfile}"
# The IP to connect to.
publicip="192.168.0.1"
# The interface to connect to.
iface="eth0"
# The name of UFW application
app="OpenSSH"

# Create an empty file on the first run.
if [ ! -e "$path" ]; 
then
	touch $path
fi

sha=$(wget  -q -O - "${semipurl}"|shasum -a 256)
# Compare the shasum of the remote file with the local file shasum. 
result=$(echo "${sha:: -2}*${semfile}" | shasum -c)

# If shasum does not match download the latest list and update ufw rules.
if [ "$result" != "${semfile}: OK" ];
then
	# The number is arbitrary. The idiea is to have persistent rules first.
	# In this case rules 1, 2 and 3 are persistent. Rule number 4 will be deleted.
	i=4
	# Get the number of lines in the local file.
	end=$(($(wc -l < $path) + $i - 1))
	# Delete non-persistent rules.
	while [ $i -le $end ]; do
    		echo "Deleting rule ${i}"
    		echo "y" | sudo ufw delete 4
    		i=$(($i + 1))
	done
	# Get the updated list of Semaphore IPs.
	wget -O $path "${semipurl}"
	# Add rule for each listed IP.
	while IFS= read -r semip
	do
        	# Add an ufw rule for the given IP.
		printf 'Adding rule for %s\n' "$semip"
		sudo ufw allow in on "${iface}" to "${publicip}" from "${semip}" app "${app}"
	done <"$path"
else
	echo "No Sem 2 IP changes."
fi

