
# Stop the q-node
systemctl stop ceremonyclient.service

# Check whether some files are updated in the ceremonyclient git repo
cd ~/ceremonyclient
git fetch origin

# Update code
git merge origin

# Clear all previous build files
cd ~/ceremonyclient/node
GOEXPERIMENT=arenas go clean -v -n -a ./...

# Remove the compiled go binary file node
rm /root/go/bin/node
ls /root/go/bin

# Make a new build compiled binary file node
GOEXPERIMENT=arenas go install  ./...
ls /root/go/bin

# Start the q-node
systemctl start ceremonyclient.service
systemctl status ceremonyclient.service

# disabling
# systemctl disable ceremonyclient.service
