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

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disabling nodejs is"


dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabling nodejs:20 is"


dnf install nodejs -y &>>$LOG_FILE
validate $? "installation of nodejs:20 is"

id expense
if[ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    validate $? "expense user creation is"
else
    echo "expense user already got created"
fi

mkdir -p /app
validate $? "folder creation is"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
validate $? "Downloading of backend code is"

cd /app 
rm -rf /app/* &>>$LOG_FILE
validate $? "removing of files in /app folder is"

unzip /tmp/backend.zip &>>$LOG_FILE
validate $? "Extraction of backend code is"

npm install &>>$LOG_FILE
validate $? "Installation of dependencies of the application is"

cp /home/ec2-user/shellscriptingpractice/backend.service  /etc/systemd/system/backend.service $>>$LOG_FILE
validate $? "copying of service file to the etc folder is"

system daemon-reload &>>$LOG_FILE
validate $? "daemon reload is"

systemctl enable backend &>>$LOG_FILE
validate $? "enabling of backend service is"

systemctl start backend &>>$LOG_FILE
validate $? "starting of backend is"


dnf install mysql -y &>>$LOG_FILE
validate $? "mysql client installation is"

#systemctl status backend &>>$LOG_FILE
#validate $? "status of backend is"
mysql -h db.expensesnote.site -uroot -p$PASSWORD < /app/schema/backend.sql &>>$LOG_FILE
validate $? "schema loading is"

systemctl restart backend &>>$LOG_FILE
validate $? "restarting of backend is"






