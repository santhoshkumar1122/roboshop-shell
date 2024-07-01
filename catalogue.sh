#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_HOST=192.168.52.130

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$2 ... $R FAILED $N"
    else
       echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
   echo -e "$R ERROR:: Please run this script with root access $N"
   exit 1 # we can give other than 0
else
   echo "you are a root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current NodeJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling NodeJS18" 

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? "Installing nodejs" 

useradd roboshop  &>> $LOGFILE

VALIDATE $? "Creating roboshop user" 

mkdir /app

VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application" 

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/santhosh/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload" &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue" &>> $LOGFILE

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue date into mongodb"






