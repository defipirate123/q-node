#!/bin/bash
# Run this to install q-node

sudo apt -q update > /dev/null 2>&1
sudo apt install git -y > /dev/null 2>&1

# Download the distribution source
wget  https://go.dev/dl/go1.20.14.linux-amd64.tar.gz > /dev/null 2>&1

# Extract the zipped (gz) file
sudo tar -xvf go1.20.14.linux-amd64.tar.gz > /dev/null 2>&1

# Move the GO folder to usr folder
sudo mv go /usr/local > /dev/null 2>&1

# Delete (remove) the downloaded GO zipped file
sudo rm go1.20.14.linux-amd64.tar.gz > /dev/null 2>&1

# Permanently set GO environment variables
echo -e "\n# Adding Go environment variables" >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc

# Source the updated ~/.bashrc to apply changes
source ~/.bashrc

echo "Go environment variables added to ~/.bashrc"

# Append network buffer size configurations to /etc/sysctl.conf
echo -e "\n# Increase buffer sizes for better network performance" >> /etc/sysctl.conf
echo 'net.core.rmem_max=600000000' >> /etc/sysctl.conf
echo 'net.core.wmem_max=600000000' >> /etc/sysctl.conf

# Apply the changes using sysctl
sudo sysctl -p > /dev/null 2>&1

echo "Network buffer sizes updated in /etc/sysctl.conf"

# Clone the Quilibrium CeremonyClient Repository
cd ~
git clone  https://github.com/QuilibriumNetwork/ceremonyclient.git > /dev/null 2>&1
echo "Cloned the Quilibrium CeremonyClient Repository"

# Run " go run " once to Create your Q Wallet and .config folder
cd ~/ceremonyclient/node
GOEXPERIMENT=arenas go run ./... > /dev/null 2>&1 &
echo "Running q-node to create your Q Wallet and .config folder"

# Adding a 1000-second delay
sleep 1000

# Kill that process
pid=$!
kill $pid
echo "Killing q-node..."

# Configure your Node Network Firewall
echo "y" | sudo ufw enable > /dev/null 2>&1
sudo ufw allow 22 > /dev/null 2>&1
sudo ufw allow 8336 > /dev/null 2>&1
sudo ufw allow 443 > /dev/null 2>&1
sudo ufw status > /dev/null 2>&1

# Configure your config.yml
cd ~/ceremonyclient/node

# Find and replace the listenGrpcMultiaddr field in .config/config.yml
sudo sed -i 's/listenGrpcMultiaddr: ""/listenGrpcMultiaddr: \/ip4\/127.0.0.1\/tcp\/8337/' .config/config.yml > /dev/null 2>&1

echo "Config.yml updated with new listenGrpcMultiaddr value"

# Build the node Binary in /root/go/bin Folder
GOEXPERIMENT=arenas go install  ./... > /dev/null 2>&1

# Create and configure /lib/systemd/system/ceremonyclient.service
sudo tee /lib/systemd/system/ceremonyclient.service > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
CPUQuota=600%
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
Environment=GOEXPERIMENT=arenas
ExecStart=/root/go/bin/node ./...

[Install]
WantedBy=multi-user.target
EOF

echo "ceremonyclient.service file created and configured"

# Setup service so that it autostarts on reboot
systemctl enable ceremonyclient.service > /dev/null 2>&1

# Setup gRPC
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest > /dev/null 2>&1
echo "installing gRPC..."

echo "Rebooting now..."
reboot
