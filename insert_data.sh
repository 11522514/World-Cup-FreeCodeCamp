#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $WINNER_TEAM_ID ]]
    then
      WINNER_TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $WINNER_TEAM_INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted $WINNER into teams"
      fi
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      OPPONENT_TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $OPPONENT_TEAM_INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted $OPPONENT into teams"
      fi
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE round='$ROUND' AND winner_id='$WINNER_TEAM_ID' AND opponent_id='$OPPONENT_TEAM_ID' AND year=$YEAR")
    if [[ -z $GAME_ID ]]
    then
      GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $GAME_INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted $YEAR $ROUND into games"
      fi
    fi
  fi
done
