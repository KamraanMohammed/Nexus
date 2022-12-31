#!/bin/bash
# Nexus-Install.SH
# This script will install tomcat on Linux (Debian and RedHat based distributions)

#DEFINE COLORS
Red='\033[1;31m'
Green='\033[1;32m'
NC='\033[0;m'

#ENFORCE ROOT USER
if [[ ! $(whoami) == root ]]
then
        echo -e "${Red}This script must be executed as root user"
        echo "Switch to root user or run this script with sudo"
        sleep 1
        echo -e "Exiting... ${NC}" 
        exit 1
fi

# CHECK LINUX DISTRIBUTION
str=$(grep  "^ID=" /etc/os-release)
IFS='='
read -a strarr <<< "$str"
distro=$(echo ${strarr[@]} |awk '{print $NF}')

DEBIAN=("debian" "ubuntu")
RHEL=("rhel" "centos" "amzn")

# Check for value matching
if [[ " ${RHEL[@]} " =~ " ${distro} " ]]
then
        dist=rhel
elif [[ " ${DEBIAN[@]} " =~ " ${distro} " ]]
then
        dist=deb
else
        echo -e "${Red}Unable to determine the distribution for this system."
        echo "Nexus installation will therefore not proceed"
        echo -e "Exiting...${NC}"
        exit 1
fi


# INSTALL JAVA IF NOT PRESENT
if [[ ! -d /usr/lib/jvm ]]
then
        if [[ $(echo $dist) == deb ]]
        then
		apt update 
                apt install openjdk-8-jre-headless -y
        else
                yum install openjdk-8-jre-headless -y
        fi
fi

# Download necessary packages
if [[ ! -f /usr/bin/wget ]]
then
        sudo yum install wget -y
fi


# Download Nexus
if [[ -d /opt/nexus ]];then
        echo -e "${Green}Nexus Already Installed..\nProceeding to configure${NC}"
else
        cd /opt
        wget -c https://download.sonatype.com/nexus/3/latest-unix.tar.gz
        tar -zxvf latest-unix.tar.gz
        rm -rf latest-unix.tar.gz
        
fi
sleep 2

# Move Nexus files and Create Nexus user
mv nexus* nexus
adduser nexus
sudo visudo

	#When promted add the following line
	#nexus ALL=(ALL) NOPASSWD: ALL

#Give ownership to Nexus user
chown -R nexus:nexus /opt/nexus*
chown -R nexus:nexus /opt/sonatype*
vim /opt/nexus/bin/nexus.rc
#Uncomment the file and added the nexus user as shown below:
#run_as_user="nexus"

#Run nexus as a systemd service
vim /etc/systemd/system/nexus.service
	#Past the following code
	#[Unit]
	#Description=nexus service
	#After=network.target
	#[Service]
	#Type=forking
	#LimitNOFILE=65536
	#ExecStart=/opt/nexus/bin/nexus start
	#ExecStop=/opt/nexus/bin/nexus stop
	#User=nexus
	#Restart=on-abort
	#[Install]
	#WantedBy=multi-user.target
sleep 2

# Reload the daemon and start service
systemctl daemon-reload
sleep 1
systemctl start nexus
systemctl status nexus
if [[ $(echo $?) != 0 ]];
then
        echo -e "${Red}Nexus Installation Unsuccessful"
        exit 1
fi

sleep 2

# Finish And Exit
echo -e "${Green}Nexus Installation And Configuration Successfully Completed !!!${NC}"
exit $?

