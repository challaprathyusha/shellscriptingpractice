#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter your password:"
read PASSWORD

validate(){
if [ $1 -ne 0 ]
then    
    echo -e "$2....$R FAILURE $N"
    exit 1
else
    echo -e  "$2....$G SUCCESS $N"
fi
}

if [ $USERID -ne 0 ]
then 
    echo "run the script using super user privilages"
    exit 1
else
    echo "You are super user"
fi

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Installation of mysql"

systemctl enable mysqld -y &>>$LOG_FILE
validate $? "Enabling of mysql"

systemctl start mysqld -y &>>$LOG_FILE
validate $? "starting of mysql"

mysql -h db.expensesnote.site -uroot -p$PASSWORD -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass $PASSWORD &>>$LOG_FILE
else
    echo -e "root password is already set for the rootuser so.....$Y SKIPPING $N"
    exit 1
fi

