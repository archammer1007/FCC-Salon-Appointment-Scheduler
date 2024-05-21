#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

MAIN_MENU() {
  #display message when returning to main menu
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon."
  fi

  #get available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  #display available services in menu form
  echo -e "\nHere are the available services:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #have user select a service
  echo -e "\nWhat service would you like to schedule?"
  read SERVICE_ID_SELECTED

  #check if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #send to main menu again
    MAIN_MENU "Please select a service number."
  else
    #check if number matches an existing service
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    if [[ -z $SELECTED_SERVICE_NAME ]]
    then
      #if not a valid number, send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      #get customer phone number
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      #check if customer already exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      #if customer id not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        #get customer name
        echo -e "\nI have no record for this phone number. What is your name?"
        read CUSTOMER_NAME
        #add entry for new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      #get customer appointment time
      echo -e "\nWhat time would you like your$SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      #get the customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #insert the new appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

  echo -e "\n end message"
}

MAIN_MENU