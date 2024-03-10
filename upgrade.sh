systemctl stop ceremonyclient.service
cd ~/ceremonyclient
git fetch origin
git merge origin
cd ~/ceremonyclient/node
GOEXPERIMENT=arenas go clean -v -n -a ./...
rm /root/go/bin/node
ls /root/go/bin
GOEXPERIMENT=arenas go install  ./...
ls /root/go/bin
systemctl start ceremonyclient.service
systemctl status ceremonyclient.service