#!/bin/sh

# Copyright (C) 2021 Mark D. Blackwell.

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.

#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Contact: Mark D. Blackwell
# markdblackwell01@gmail.com

#--------------

set -e
#limit=7
#size=`expr $limit + 3`
#for neg in $(seq -$size -1); do
# for pos in $(seq 1 $size); do
#for neg in $(seq -23 -21); do
for first in $(seq 22 22); do
  neg=-$first
  for pos in $(seq 10 10); do
#   if [ $pos -ge $limit -a $neg -le -$size ]; then
#     continue
#   fi
    echo $neg $pos
    nice ruby lib/TemperamentMath/Calculate/calculate.rb $neg $pos
  done
done
