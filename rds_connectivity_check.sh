#!/bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This is a Amazon Relational Database Endpoint connectivity Check Script       #
#       Date: 07/03/2023                                                                           #
#       Modified Date: 07/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#

RDS_MYSQL_ENDPOINT="your-endpoint-goes-here";
RDS_MYSQL_USER="your-username-goes-here";
RDS_MYSQL_PASS="your-password-goes-here";
RDS_MYSQL_BASE="your-database-name-goes here";
SERVER_LIST=`cat /home/ec2-user/list.txt`

for server_ip in list
do
  ssh $server_ip 'mysql -h $RDS_MYSQL_ENDPOINT -u $RDS_MYSQL_USER -p$RDS_MYSQL_PASS -D $RDS_MYSQL_BASE -e 'quit';'
  if [[ $? -eq 0 ]]; then
    echo "MySQL connection: OK";
  else
    echo "MySQL connection: Fail";
  fi;
done
