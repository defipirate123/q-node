
input_file="nodes"

# Read each line (IP address) from the file
while IFS= read -r ip_address; do
    echo "Executing commands on $ip_address..."

    # SSH into the remote machine and execute the commands
    ssh root@$ip_address "sudo systemctl stop ceremonyclient.service"
    ssh root@$ip_address "cd ~/ceremonyclient && git fetch origin && git merge origin"
    ssh root@$ip_address "cd ~/ceremonyclient/node && GOEXPERIMENT=arenas go clean -v -n -a ./..."
    ssh root@$ip_address "cd ~/ceremonyclient/node && rm /root/go/bin/node"
    ssh root@$ip_address "cd ~/ceremonyclient/node && ls /root/go/bin"
    ssh root@$ip_address "cd ~/ceremonyclient/node && sleep 5 && GOEXPERIMENT=arenas go install ./..."
    ssh root@$ip_address "cd ~/ceremonyclient/node && sleep 5 && ls /root/go/bin"
    ssh root@$ip_address "sudo systemctl start ceremonyclient.service"
    ssh root@$ip_address "sudo systemctl status ceremonyclient.service"

    echo "Commands executed on $ip_address."
done < "$input_file"