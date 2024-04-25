#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL"TRUNCATE TABLE games, teams") # To restart the table new eacht time
echo $($PSQL"ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL"ALTER SEQUENCE games_game_id_seq RESTART WITH 1")

# read in function and define seperator
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do
  if [[ $YEAR != "year" ]]
  then
    # Get first name; to check current db row if it already exists
    NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    # If not found, Insert Team name from winner colum
    if [[ -z $NAME ]]
    then
      INSERT_TEAMS=$($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAMS == "INSERT 0 1" ]]
      then
        echo 'Inserted into year , $WINNER'
      fi   
    fi

    # get opp value for the same row
    NAME_OPP=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $NAME_OPP ]]   
    then
      # Insert Team name from Opponent if still missing
      INSERT_TEAMS_MISS=$($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAMS_MISS == "INSERT 0 1" ]]
      then
        echo 'Additional inserted into year , $OPPONENT'
      fi 
    fi 

    #

  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do
  if [[ $YEAR != "year" ]]
  then
    # Winner ID and OPPONENT ID - Retrieve via Team_ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert into db row
    INSERT_RESULTS=$($PSQL"INSERT INTO games(winner_id,opponent_id,winner_goals,opponent_goals,year,round) VALUES($WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS,$YEAR,'$ROUND')")
    if [[ $INSERT_RESULTS == "INSERT 0 1" ]]
    then
      echo 'Inserted into row: , games columns'
    fi     
  fi
done




