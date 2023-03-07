#!/bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This is an installer script for Java-1.8.0-Openjdk                            #
#       Date: 07/03/2023                                                                           #
#       Modified Date: 07/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#

USER="ec2-user"
export HOSTS=`cat /home/ec2-user/hosts`

for HOST in $HOSTS
do
  ssh $USER@$HOST 'java -version 2> /dev/null'
  if [[ $? -eq 0 ]]; then
      echo "Java is Already Installed.";
      echo -e "\n"
      exit
  else
      echo "Java is Not Installed Yet, Hence Proceeding with the Installation.";
      echo -e "\n"
      ssh $USER@$HOST 'sudo yum install -y java-1.8.0-openjdk > /dev/null 2>&1'
      ssh $USER@$HOST 'sudo yum install -y java-1.8.0-openjdk-devel > /dev/null 2>&1'
      ssh $USER@$HOST 'sudo mkdir /usr/java'
      ssh $USER@$HOST 'sudo ln -s /usr/lib/jvm/java-openjdk /usr/java/latest'
      ssh $USER@$HOST 'sudo ln -s /usr/java/latest /usr/java/default'
      echo "Java Installed Successfully.";
      echo -e "\n"
  fi;
done
