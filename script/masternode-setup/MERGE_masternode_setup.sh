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
sudo apt-get install -y build-essential autoconf automake libssl1.0-dev libdb5.3-dev libdb5.3++-dev libboost-all-dev pkg-config libtool libevent-dev git screen autotools-dev bsdmainutils lsof dos2unix zlib1g-dev
sudo apt-get install -y ufw
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
wget https://github.com/ProjectMerge/merge/releases/download/1.0.0/merge-testnet-1.0.0-linux64.tar.gz
tar -xf merge-testnet-1.0.0-linux64.tar.gz
rm merge-testnet-1.0.0-linux64.tar.gz

echo "Masternode Configuration"
echo "Type the IP address for this masternode, followed by [ENTER]: "
read IP
echo "Enter the masternode's private key, followed by [ENTER]: "
read PRIVKEY
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
./merged -resync
echo "If the server fails to start, try ./merged -reindex"
echo ""

echo "****************************************************************************"
echo "*                      Your masternode is now setup.                       *"
echo "*              Please continue with the Post-requisites steps.             *"
echo "*                                                                          *"
echo "*                                  Merge                                   *"
echo "****************************************************************************"
echo ""