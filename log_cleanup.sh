#!/bin/bash

#==========================================================================================================#
#   Author: Sugumar Srinivasan                                                                             #
#   NTID: ssrke                                                                                            #
#   Creation Date: 03/08/2022                                                                              #
#   Modified Date: 03/08/2022                                                                              #
#   Description: This shell script will clean_up the older files based on the user input(FILE_PATH, USER,  #
#                GROUP, DURATION).                                                                         #
#                                                                                                          #
#   Syntax:  sh log_cleanup.sh <LOG_PATH> <USER> <GROUP> <DURATION>                                        #
#   Example: sh log_cleanup.sh /allstate/log/ hadoop hadoop 90                                             #
#==========================================================================================================#

LOG_PATH=$1
USER=$2
GROUP=$3
DURATION=$4

#find $LOG_PATH -type f -user $USER -group $GROUP -mtime +$DURATION -exec ls {} \; | wc -l
find $LOG_PATH -type f -user $USER -group $GROUP -mtime +$DURATION -exec rm -rf {} \;
