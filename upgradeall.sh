#!/bin/bash

# Replace 'file_with_ips.txt' with the actual path to your file containing IP addresses
input_file="nodes1"

# Read each line (IP address) from the file
while IFS= read -r ip_address; do
    echo "Executing commands on $ip_address..."

    # SSH into the remote machine and execute the commands
    ssh root@$ip_address "sudo systemctl stop ceremonyclient.service"
    ssh root@$ip_address "cd ~/ceremonyclient && git fetch origin && git merge origin"

    # Use the path to the go binary 
    go_path=/usr/local/go/bin/go
    if [[ -n "$go_path" ]]; then
        ssh root@$ip_address "cd ~/ceremonyclient/node && GOEXPERIMENT=arenas $go_path clean -v -n -a ./..."
        ssh root@$ip_address "cd ~/ceremonyclient/node && $go_path install ./..."
    else
        echo "Error: go binary not found on $ip_address."
    fi

    ssh root@$ip_address "sudo systemctl start ceremonyclient.service"
    ssh root@$ip_address "sudo systemctl status ceremonyclient.service"

    echo "Commands executed on $ip_address."
done < "$input_file"