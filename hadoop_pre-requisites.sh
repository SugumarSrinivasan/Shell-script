#!bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This is a pre-requisite validation script for Apache-Hadoop                   #
#       Date: 09/03/2023                                                                           #
#       Modified Date: 09/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#

USER="ec2-user"
function memoryCheck() {
      echo -e "Available Memory: \t [ `free -h | awk '/^Mem:/{print $7}'` ]"
}

function diskCheck() {
echo -e "Available Disk on /: \t [ `df -H / | grep -vE '^Avail' | awk '{ print $4 }' | tail -1` ]"
}

function sudo_privilege_check() {
sudo -v -u $USER  > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "SUDO PREVILIGE: \t [ Yes ]"
else
    echo -e "SUDO PREVILIGE: \t [ No ]"
fi
}
function selinux_check() {
#SESTATUS=`getenforce`
if [ $((getenforce)) == "Enforcing" ]
then
    echo -e "SELINUX STATUS: \t [ Enabled ]"
else
    echo -e "SELINUX STATUS: \t [ Disabled ]"
fi
}
function java_installation_check() {
java -version  > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "JAVA STATUS: \t\t [ Installed ]"
else
    echo -e "JAVA STATUS: \t\t [ Not Installed ]"
fi
}
function python3_installation_check() {
python3 -V > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "PYTHON3 STATUS: \t [ Installed ]"
else
    echo -e "PYTHON3 STATUS: \t [ Not Installed ]"
fi
}

function krb5_server_check() {
rpm -qa | grep krb5-server-* > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "KRB5 SERVER: \t\t [ Installed ]"
else
    echo -e "KRB5 SERVER: \t\t [ Not Installed ]"
fi
}

function krb5_workstation_check() {
rpm -qa | grep krb5-workstation-* > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "KRB5 WORKSTATION: \t [ Installed ]"
else
    echo -e "KRB5 WORKSTATION: \t [ Not Installed ]"
fi
}

function chrony_installation_check() {
rpm -qa | grep chrony-* > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo -e "CHRONYD: \t\t [ Installed ]"
else
    echo -e "CHRONYD: \t\t [ Not Installed ]"
fi
}

function vm_swappiness_check() {
VM_SWAPPINESS=`cat /proc/sys/vm/swappiness`
if [ $((VM_SWAPPINESS)) -ne 1 ]
then
    echo -e "VM SWAPPINESS CHANGE: \t [ Required ]"
else
   echo "VM SWAPPINESS CHANGE: \t [ Not Required ]"
fi
}

function thp_disabled_check() {
HUGEPAGES=`grep -i HugePages_Total /proc/meminfo | awk '{print $2}'`
if [ $((HUGEPAGES)) -ne  0 ]
then
    echo -e "THP STATUS: \t\t [ Enabled ]"
else
   echo -e "THP STATUS: \t\t [ Disabled ]"
fi
}
echo -e "\n"
echo "Validation of Hadoop Pre-requisites in `hostname`:"
echo -e "\n"
memoryCheck
diskCheck
sudo_privilege_check
selinux_check
java_installation_check
python3_installation_check
krb5_server_check
krb5_workstation_check
chrony_installation_check
vm_swappiness_check
thp_disabled_check
echo -e "\n"
