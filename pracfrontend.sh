#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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

dnf install nginx -y &>>$LOG_FILE
validate $? "Installation of nginx is"


systemctl enable nginx &>>$LOG_FILE
validate $? "enabling of nginx is"


systemctl start nginx &>>$LOG_FILE
validate $? "starting of nginx is"

cd /usr/bin/nginx/html
rm -rf /usr/bin/nginx/html/* &>>$LOG_FILE

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
validate $? "Downloading of frontend code is"

cd /usr/bin/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE


cp /home/ec2-user/shellscriptingpractice/pracexpense.config  /etc/nginx/default.d/expense.conf &>>$LOG_FILE
validate $? "copying of configuration file is"

systemctl restart nginx &>>$LOG_FILE
validate $? "restarting of nginx is"