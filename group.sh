#!/bin/sh

#  first=`expr 0 - $neg - 2`
#  last=`expr $neg + 2`

for neg in $(seq -7 -1); do
  for pos in $(seq 1 7); do
    echo $neg $pos
    nice ruby lib/TemperamentMath/Calculate/calculate.rb $neg $pos
  done
done


