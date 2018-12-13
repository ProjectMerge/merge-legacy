#/bin/bash
cd ~
rm -rf MERGE_masternode_setup.sh*
echo "****************************************************************************"
echo "* This script will install and configure your MERGE masternodes.           *"
echo "*                     							 *"
echo "*    If you have any issues please ask for help on the MERGE discord.      *"
echo "*                      https://discord.gg/b88VWfB                          *"
echo "*                        https://projectmerge.org/                         *"
echo "****************************************************************************"
echo ""
echo ""
echo ""
echo "****************************************************************************"
echo "* 		      Express Installation Script	 		 *"
echo "****************************************************************************"
echo ""
echo ""
echo ""
echo "Do you want to use our Masternode/Wallet installation? [y/n], followed by [ENTER]"
read setup
	rm -rf MERGE_masternode_setup.sh*
	./merge-cli stop
	echo "Configure your VPS with MERGE recommended settings"
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
	echo ""
	echo "installing/updating your Masternode"
	./merge-cli stop
	rm merged
	rm merge-cli
	rm merge-tx
	wget https://github.com/ProjectMerge/merge/releases/download/1.0.0/merge-testnet-1.0.0-linux64.tar.gz
	tar -xf merge-testnet-1.0.0-linux64.tar.gz
	rm merge-testnet-1.0.0-linux64.tar.gz

echo "Masternode Configuration"
echo "Your IP address is:"
sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'

echo "Is this the IP you wish to use for MasterNode? [y/n] , followed by [ENTER]"
read ipd
	if [[ $ipd =~ "y" ]] || [[$ipd =~ "Y" ]] ; then
	echo ""
	echo "Using your default IP address"
	echo "Enter masternode private key for node, followed by [ENTER]: $ALIAS"
	read PRIVKEY
	CONF_DIR=~/.MERGE\/
	CONF_FILE=MERGE.conf
	PORT=62000
	IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
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
	echo "if server start failure try ./merged -reindex"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!                                                 !"
	echo "! Your MasterNode is setup please close terminal  !"
	echo "!   and continue the local wallet setup guide     !"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo ""
else
	echo "Type the custom IP of this node, followed by [ENTER]:"
	read DIP
	echo ""
	echo "Enter masternode private key for node, followed by [ENTER]: $ALIAS"
	read PRIVKEY
	CONF_DIR=~/.MERGE\/
	CONF_FILE=MERGE.conf
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
	echo "masternodeaddr=$DIP:$PORT" >> $CONF_DIR/$CONF_FILE
	echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/$CONF_FILE
	./merged -resync
	echo "if server start failure try ./merged -reindex"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!                                                 !"
	echo "! Your MasterNode is setup please close terminal  !"
	echo "!   and continue the local wallet setup guide     !"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo ""
fi
