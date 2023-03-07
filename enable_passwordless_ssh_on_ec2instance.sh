#!/bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This is a passwordless-ssh enabling script on AWS EC2 Instances               #
#       Date: 07/03/2023                                                                           #
#       Modified Date: 07/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#

USER="ec2-user"
PEM_PATH="/home/ec2-user/sugumardevops.pem"
SSH_KEY_PATH="/home/ec2-user/.ssh/id_rsa.pub"
HOSTS=`cat /home/ec2-user/hosts`

for HOST in $HOSTS
do
                echo -e "Generating Private/Public Keypair on $HOST \n"
                ssh -i $PEM_PATH $USER@$HOST "ssh-keygen -t rsa -N '' -f /home/ec2-user/.ssh/id_rsa" > /dev/null 2>&1
done

for HOST in $HOSTS
do
                scp -i $PEM_PATH $USER@$HOST:/home/ec2-user/.ssh/id_rsa.pub /home/ec2-user/"$HOST"_id_ras.pub > /dev/null 2>&1
                cat /home/ec2-user/"$HOST"_id_ras.pub >> /home/ec2-user/public_keys
done

for HOST in $HOSTS
do
                scp -i $PEM_PATH /home/ec2-user/public_keys $USER@$HOST:/home/ec2-user/ > /dev/null 2>&1
                ssh -i $PEM_PATH $USER@$HOST "cat /home/ec2-user/public_keys >> /home/ec2-user/.ssh/authorized_keys" > /dev/null 2>&1
done
