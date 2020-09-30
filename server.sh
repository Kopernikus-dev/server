#!/bin/bash
PORT=43013
RPCPORT=43014
CONF_DIR=~/.encocoin
COIN_NAME='EncoCoin'
cd ~
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
if [[ $(lsb_release -d) = *18.04* ]]; then
  COINZIP='https://github.com/Kopernikus-dev/xnk-testing/releases/download/v3.2.0/encocoin-v3.2.0-ubuntu1804.zip'
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

function configure_systemd {
  cat << EOF > /etc/systemd/system/encocoin.service
[Unit]
Description=Encocoin Service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=/root/.encocoin/encocoind.pid
ExecStart=/usr/local/bin/encocoind
ExecStop=-/usr/local/bin/encocoin-cli stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  sleep 6
  crontab -l > cronakc
  echo "@reboot systemctl start encocoin" >> cronakc
  crontab cronakc
  rm cronakc
  systemctl start encocoin.service
}

echo ""
echo ""
DOSETUP="y"

if [ $DOSETUP = "y" ]  
then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install zip unzip nano -y
  sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl1.0-dev libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libboost-all-dev libboost-program-options-dev libsodium-dev cargo -y
  sudo apt-get install libminiupnpc-dev libzmq3-dev libprotobuf-dev protobuf-compiler libqrencode-dev libgmp3-dev ufw -y
  apt-get update && apt-get dist-upgrade -y && apt install nano htop -y && apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev -y && apt-get install libboost-all-dev git libminiupnpc-dev -y && apt-get install software-properties-common -y && apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl bsdmainutils libminiupnpc-dev libgmp3-dev pkg-config libevent-dev unzip && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt-get update -y && sudo apt-get install libdb4.8-dev libdb4.8++-dev -y && sudo apt-get install make automake cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 -y && sudo apt-get install curl librsvg2-bin libtiff-tools bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python-setuptools -y && apt-get install libzmq3-dev -y && apt-get install libdb5.3++-dev iotop -y && sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt-get update -y && sudo apt-get install gcc-4.9 -y && sudo apt-get upgrade libstdc++6 -y
  sudo add-apt-repository ppa:bitcoin/bitcoin -y
  sudo apt-get update
  sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd
  
  wget $COINZIP
  unzip *.zip
  chmod +x encocoin*
  rm *-qt *-tx *.zip
  sudo cp encocoin* /usr/local/bin
  mkdir -p encocoin
  sudo mv encocoin-cli encocoind /root/encocoin
  
  mkdir -p $CONF_DIR
	cd $CONF_DIR
  wget https://github.com/Kopernikus-dev/xnk-testing/releases/download/v3.2.0/Bootstrap-v3.2.0.zip
  unzip Bootstrap-v3.2.0.zip
  rm Bootstrap-v3.2.0.zip

  sudo echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$PORT${NC}"
  sudo ufw allow $PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  sudo ufw allow ssh comment "SSH" >/dev/null 2>&1
  sudo ufw limit ssh/tcp >/dev/null 2>&1
  sudo ufw default allow outgoing >/dev/null 2>&1
  sudo echo "y" | ufw enable >/dev/null 2>&1
fi

 IP=$(curl -s4 api.ipify.org)
 echo ""
 echo "Configure your EncocoinServer now!"
 echo "Detecting IP address:$IP"
 echo ""
 
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> encocoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> encocoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> encocoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> encocoin.conf_TEMP
  echo "server=1" >> encocoin.conf_TEMP
  echo "daemon=1" >> encocoin.conf_TEMP
  echo "" >> encocoin.conf_TEMP
  echo "connect=xnk-new.cryptoscope.cc:43013" >> encocoin.conf_TEMP
  echo "addnode=164.68.102.158:43013" >> encocoin.conf_TEMP
  echo "addnode=167.86.103.113:43013" >> encocoin.conf_TEMP
  echo "addnode=199.247.28.71:43013" >> encocoin.conf_TEMP
  echo "addnode=136.244.84.74:43013" >> encocoin.conf_TEMP
  echo "addnode=178.127.13.167:43013" >> encocoin.conf_TEMP
  echo "addnode=217.69.3.147:43013" >> encocoin.conf_TEMP
  echo "addnode=95.179.177.82:43013" >> encocoin.conf_TEMP
  echo "addnode=78.141.242.75:43013" >> encocoin.conf_TEMP
  echo "addnode=45.32.158.197:43013" >> encocoin.conf_TEMP
  mv encocoin.conf_TEMP $CONF_DIR/encocoin.conf
  echo ""
  echo -e "Your ip is ${GREEN}$IP:$PORT${NC}"

	## Config Systemctl
	configure_systemd
  
echo ""
echo "Commands:"
echo -e "Start Encocoin Service: ${GREEN}systemctl start encocoin${NC}"
echo -e "Check Encocoin Status Service: ${GREEN}systemctl status encocoin${NC}"
echo -e "Stop Encocoin Service: ${GREEN}systemctl stop encocoin${NC}"
echo -e "Check Masternode Status: ${GREEN}encocoin-cli getinfo${NC}"

echo ""
echo -e "${GREEN}Encocoin Server Installation Done${NC}"
exec bash
exit
