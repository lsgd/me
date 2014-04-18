#!/bin/sh

printf 'Enter username: '
read -r USERNAME
printf "Enter password: "
read -r PASSWORD
printf "Enter database name ${USERNAME}_[base]: "
read -r DB

if [ -z "$DB" ]; then
  DB="base"
fi

DB="${USERNAME}_$DB"

echo ""
echo "Please confirm the following information:"
echo "  Username:      $USERNAME"
echo "  Password:      $PASSWORD"
echo "  Database name: $DB"
echo ""
printf "Are these information correct? [y/n] : "
read -r CORRECT

echo ""

if [ "$CORRECT" != "y" ]; then
  echo "CANCEL!"
  exit
fi

SQLFILE="/tmp/dbcreate.$(date +'%s%N')"

#echo "create database $DB CHARACTER SET utf8 COLLATE utf8_general_ci;\n" > $SQLFILE
echo "grant SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, EXECUTE, CREATE ROUTINE, ALTER ROUTINE, LOCK TABLES on $DB.* to '$USERNAME'@'localhost';\n" >> $SQLFILE
echo "set password for $USERNAME@'localhost' = password('$PASSWORD');\n" >> $SQLFILE
echo "flush privileges;\n" >> $SQLFILE

echo "Please enter the password of your MySQL root user:"
mysql -u root -p < $SQLFILE
rm $SQLFILE

echo ""
echo "Successful!"
