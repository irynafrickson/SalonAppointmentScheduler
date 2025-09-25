#!/bin/bash
PSQL='psql -X --username=freecodecamp --dbname=salon --tuples-only -c'

echo -e "\n~~~ Salon Appointment Scheduler ~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

# display and select services
DISPLAY_AND_SELECT_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "\nHere are our services:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done  

  # prompt for service
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    DISPLAY_AND_SELECT_SERVICES "That is not a valid service number."
  else
    # get service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    # if no such service
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      DISPLAY_AND_SELECT_SERVICES "Sorry, we don't have that service."
    else
      # format service name
      SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')
      # print selected service
      echo -e "\nYou selected $SERVICE_NAME_SELECTED_FORMATTED"
      # get customer info
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if no such customer in database
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # format customer name
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
      # prompt for time
      echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME
      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
      
      echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}

DISPLAY_AND_SELECT_SERVICES
