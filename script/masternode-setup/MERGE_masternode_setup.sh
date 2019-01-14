#/bin/bash
cd ~
rm -rf MERGE_masternode_setup.sh*
echo "****************************************************************************"
echo "*       This script will install and configure your MERGE masternode       *"
echo "*                             (Remote Wallet)                              *"
echo "*                                                                          *"
echo "*      If you have any issues, please ask for help on Merge's Discord:     *"
echo "*                        https://discord.gg/b88VWfB                        *"
echo "*                                                                          *"
echo "*                         https://projectmerge.org                         *"
echo "****************************************************************************"
echo ""
echo ""
echo "****************************************************************************"
echo "*                           Installation Script                            *"
echo "****************************************************************************"
echo ""
echo ""

echo "Hit [ENTER] to start the masternode setup"
read setup
rm -rf MERGE_masternode_setup.sh*
./merge-cli stop
echo "Configuring your VPS with the recommended settings..."
sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y libssl1.0-dev
sudo apt-get install -y libdb5.3-dev
sudo apt-get install -y libdb5.3++-dev
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y pkg-config
sudo apt-get install -y libtool
sudo apt-get install -y libevent-dev
sudo apt-get install -y git
sudo apt-get install -y screen
sudo apt-get install -y autotools-dev
sudo apt-get install -y bsdmainutils
sudo apt-get install -y lsof
sudo apt-get install -y dos2unix
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y curl
sudo apt-get install -y ufw
sudo apt-get install -y curl
sudo apt-get install -y ufw
sudo apt-get install -y software-properties-common 
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw logging on
sudo ufw allow 22
sudo ufw allow 62000
echo "y" | sudo ufw enable
sudo ufw status
echo ""
echo ""
echo "Installing/Updating your masternode..."
./merge-cli stop
rm merged
rm merge-cli
rm merge-tx
# Retrieve the latest wallet release
LATEST_RELEASE_URL=https://api.github.com/repos/ProjectMerge/merge/releases/latest
FILE_ENDIND=x86_64-linux-gnu.tar.gz
release_file_url=$(curl -s $LATEST_RELEASE_URL | grep "browser_download_url.*$FILE_ENDIND" | cut -d : -f 2,3 | tr -d \")
release_file_name=$(basename $release_file_url)
wget $release_file_url
tar -xf $release_file_name
rm $release_file_name

echo "Masternode Configuration"
# Ask for the IP address
IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tail -n 1)
echo "Your IP address is: $IP"
echo "Is this the IP address you wish to use for your masternode? [y/n], followed by [ENTER]"
read ipd
if [[ $ipd =~ "n" ]] || [[ $ipd =~ "N" ]] ; then
	echo "Type the custom IP address for this masternode, followed by [ENTER]: "
    read IP
fi
# Ask for the masternode's private key
echo "Enter the masternode's private key, followed by [ENTER]: "
read PRIVKEY
# Edit configuration file
CONF_DIR=~/.merge\/
CONF_FILE=merge.conf
PORT=62000
mkdir -p $CONF_DIR
echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=passw"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "masternode=1" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
echo "masternodeaddr=$IP:$PORT" >> $CONF_DIR/$CONF_FILE
echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/$CONF_FILE
./bin/merged -resync
echo "If the server fails to start, try ./merged -reindex"
echo ""

echo "****************************************************************************"
echo "*                      Your masternode is now setup.                       *"
echo "*              Please continue with the Post-requisites steps.             *"
echo "*                                                                          *"
echo "*                                  Merge                                   *"
echo "****************************************************************************"
echo ""