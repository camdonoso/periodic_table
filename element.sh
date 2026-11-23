#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit
fi

ELEMENT=$1

if [[ $ELEMENT =~ ^[0-9]+$ ]]
then
  ELEMENT_INFO=$($PSQL "
  SELECT 
    e.atomic_number, e.symbol, e.name, 
    p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius,
    t.type
  FROM elements e 
  INNER JOIN properties p 
    ON e.atomic_number = p.atomic_number 
  INNER JOIN types t 
    ON p.type_id = t.type_id 
  WHERE e.atomic_number = $ELEMENT;
  ")
elif [[ $ELEMENT  =~ ^[A-Za-z]+$ ]]
then
  ELEMENT_INFO=$($PSQL "
  SELECT 
    e.atomic_number, e.symbol, e.name, 
    p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius,
    t.type
  FROM elements e 
  INNER JOIN properties p 
    ON e.atomic_number = p.atomic_number 
  INNER JOIN types t 
    ON p.type_id = t.type_id 
  WHERE e.symbol = INITCAP('$ELEMENT') OR e.name = INITCAP('$ELEMENT');
  ")    
fi

if [[ -z $ELEMENT_INFO ]]
then
    echo "I could not find that element in the database."
else
    IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< "$ELEMENT_INFO"

    ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed -E 's/^ *| *$//g')
    SYMBOL=$(echo $SYMBOL | sed -E 's/^ *| *$//g')
    NAME=$(echo $NAME | sed -E 's/^ *| *$//g')
    ATOMIC_MASS=$(echo $ATOMIC_MASS | sed -E 's/^ *| *$//g')
    MELTING_POINT=$(echo $MELTING_POINT | sed -E 's/^ *| *$//g')
    BOILING_POINT=$(echo $BOILING_POINT | sed -E 's/^ *| *$//g')
    TYPE=$(echo $TYPE | sed -E 's/^ *| *$//g')

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
