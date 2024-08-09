#!/bin/bash

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo $RANDOM_NUMBER
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME';")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_NAME=$($PSQL "INSERT INTO users(name) VALUES('$NAME');")
else
  GAMES=$($PSQL "SELECT games FROM users WHERE USER_ID = $USER_ID;")
  BEST=$($PSQL "SELECT best FROM users WHERE user_id = $USER_ID;")
  echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_GUESS=0
while true
do
  NUMBER_GUESS=$((NUMBER_GUESS + 1))
  read SECRET_NUMBER

  if [[ ! $SECRET_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $RANDOM_NUMBER < $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $RANDOM_NUMBER > $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $RANDOM_NUMBER == $SECRET_NUMBER ]]
  then
    echo "You guessed it in $NUMBER_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME';")
    INSERT_GAME=$($PSQL "UPDATE users SET games = COALESCE(games, 0) + 1 WHERE user_id = $USER_ID;") 
    INSERT_BEST=$($PSQL "UPDATE users SET best = CASE WHEN best IS NULL OR $NUMBER_GUESS < best THEN $NUMBER_GUESS ELSE best END WHERE user_id = $USER_ID;")
    break
  fi

done
