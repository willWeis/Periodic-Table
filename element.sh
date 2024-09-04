#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

INPUT=$1

if [[ -z $INPUT ]]
then
  echo "Please provide an element as an argument."
else
  # Determine if input is a number (atomic number), a symbol, or a name
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    # Input is an atomic number
    QUERY="SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number=$INPUT"
  else
    # Check length of input to determine if it's a symbol or name
    LENGTH=$(echo -n "$INPUT" | wc -m)
    if [[ $LENGTH -gt 2 ]]
    then
      # Input is a name
      QUERY="SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types ON properties.type_id=types.type_id WHERE name='$INPUT'"
    else
      # Input is a symbol
      QUERY="SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types ON properties.type_id=types.type_id WHERE symbol='$INPUT'"
    fi
  fi

  # Execute query and process the result
  DATA=$($PSQL "$QUERY")

  if [[ -z $DATA ]]
  then
    echo "I could not find that element in the database."
  else
    echo $DATA | while IFS="|" read NUMBER SYMBOL NAME WEIGHT MELTING BOILING TYPE
    do
      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $WEIGHT amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
