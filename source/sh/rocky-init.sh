#!/bin/bash 

groupadd sysadm 
echo '%sysadm ALL=NOPASSWD:ALL' >> /etc/sudoers.d/sysadm 
chmod 440 /etc/sudoers.d/sysadm 
sed -i ""s/PermitRootLogin yes/PermitRootLogin no/g"" /etc/ssh/sshd_config 
sed -i ""s/exclude=xe-guest-utilities*/exclude=xe-guest-utilities* kernel* centos-release* kmod-kvdo* initscripts/g"" /etc/yum.conf
sed -i ""s/ClientAliveCountMax 0/ClientAliveCountMax 5/g"" /etc/ssh/sshd_config 
systemctl restart sshd 
useradd -m -p $(openssl passwd -1 -salt uber Korea@1234) -g sysadm -s /bin/bash clabi 