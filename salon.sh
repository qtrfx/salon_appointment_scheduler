#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#echo "$($PSQL "SELECT * FROM services;")"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU () {
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to my Salon, how can I help you?\n"
  
  OFFERED_SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  
  echo "$OFFERED_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED

  SELECTED_SERVICE=$($PSQL "SELECT name FROM services where service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $SELECTED_SERVICE ]]
  then
  MAIN_MENU "Please enter a valid number."
  
  else
    SCHEDULING_MENU
    fi
}


SCHEDULING_MENU () {
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';");
    if [[ -z $CUSTOMER_ID ]]
    then
    echo -e "\nThe phone number is not in our database, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_ADDED_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';");
    else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    fi
    echo -e "\nWhen would you like your $(echo $SELECTED_SERVICE | sed -E 's/^ *| *$//'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')?"
    read SERVICE_TIME
    APPOINTMENT_SCHEDULED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE | sed -E 's/^ *| *$//') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')."
    echo "Thank you for being our customer!"
}
  MAIN_MENU