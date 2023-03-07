#!/bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This shell script will update the host entries in /etc/hosts                  #
#       Date: 07/03/2023                                                                           #
#       Modified Date: 07/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#

USER="ec2-user"
PEM_PATH="/home/ec2-user/sugumardevops.pem"
HOSTS=`cat /home/ec2-user/hosts`
HOST_ENTRIES=`cat /home/ec2-user/host`

for HOST in $HOSTS
do
        IFS=$'\n'
        for LINE in $HOST_ENTRIES
        do
                ssh -i $PEM_PATH $USER@$HOST "echo $LINE | sudo tee -a /etc/hosts"
        done
done
