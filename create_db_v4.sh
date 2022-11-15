#!/bin/bash
OPTION=$1

if [ $# -eq 0 ]; then
    echo
    echo "No arguments provided, Hence Please execute the shell script by following below syntax."
    echo
    echo "sh create_db.sh <OPTION>"
    echo
    echo "For example: sh create_db.sh 1"
    echo
    echo "Choose OPTION from below Lists:"
    echo
    echo "1 for create database in MYSQL."
    echo "2 for taking dbdump in MYSQL."
    echo "3 for restoring db from dump in MYSQL."
    echo "4 for create database in Hive."
    echo "5 for create schema in HBase through Phoenix shell."
    echo "6 for execute migration script for hive and hbase."
    echo
    exit 1
else
    case $OPTION in
    1)
        echo "*****Database Creation in MYSQL.*****"
        echo
        read -p "Database server:" DB_SERVER
        echo
        read -p "Database user name:" DB_USER_NAME
        echo
        echo "Database password:"
        read -s DB_PASSWORD
        echo
        read -p "Database Name:" DATABASE_NAME
        echo
        STATEMENT="CREATE DATABASE $DATABASE_NAME;"
        mysql -h $DB_SERVER -u$DB_USER_NAME -p$DB_PASSWORD -e "$STATEMENT"
        echo "$DATABASE_NAME Created Successfully."
        echo
        ;;
    2)
        echo "*****Creation of dbdump in MYSQL.*****"
        echo
        read -p "Database server:" DB_SERVER
        echo
        read -p "Database user name:" DB_USER_NAME
        echo
        echo "Database password:"
        read -s DB_PASSWORD
        echo
        read -p "Database Name:" DATABASE_NAME
        echo
        read -p "DB dump path:" DB_DUMP_PATH
        echo
        mysqldump -u$DB_USER_NAME -p$DB_PASSWORD $DATABASE_NAME -h $DB_SERVER > "$DB_DUMP_PATH"/"$DATABASE_NAME"_dump.sql
        echo "DB Dump taken successfully for $DATABASE_NAME."
        echo
        ;;  
    3)
        echo "*****Restoring the DB from dump in MYSQL.*****"
        echo
        read -p "Database server:" DB_SERVER
        echo
        read -p "Database user name:" DB_USER_NAME
        echo
        echo "Database password:"
        read -s DB_PASSWORD
        echo
	read -p "Old Database Name:" OLD_DATABASE_NAME
	echo
        read -p "Restore Database Name:" DATABASE_NAME
        echo
        read -p "DB dump path:" DB_DUMP_PATH
        echo
        cat "$DB_DUMP_PATH"/"$OLD_DATABASE_NAME"_dump.sql | mysql -h $DB_SERVER -u$DB_USER_NAME -p$DB_PASSWORD -D $DATABASE_NAME
        echo "DB restored in $DATABASE_NAME from $DB_DUMP_PATH/$DATABASE_NAME_dump.sql."
        echo
        ;;       
    4)
        echo "*****Database Creation in Hive*****"
        read -p "Database name:" HIVE_DB_NAME
        echo
        STATEMENT="CREATE DATABASE $HIVE_DB_NAME;"
        hive -e "$STATEMENT"
        echo "$HIVE_DB_NAME Created Successfully."
        echo
        ;;
    5)
        echo "*****Database Creation in HBase through phoenix*****"
        echo
        read -p "DB Schema name:" HBASE_SCHEMA_NAME
        echo
        read -p "SQL file Path:" SQL_PATH
        echo "CREATE SCHEMA IF NOT EXISTS "$HBASE_SCHEMA_NAME";" > "$SQL_PATH"/create_schema.sql
        ~/tdss/phoenix/bin/psql.py localhost "$SQL_PATH"
        echo "$HBASE_SCHEMA_NAME Created Successfully." 
        echo
        ;;
    6)
        echo "Migrations for hive and hbase - v4.0.1 to previous release."
        echo
        read -p "Migration script Path:" SCRIPT_PATH
        sh $SCRIPT_PATH
        echo
        ;;	    
    *)
        echo "choose the valid option"
	echo
        ;;
    esac
fi
