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

ruby -W lib/TemperamentMath/calculate.rb

diff test/fixture/output-main-n2-p2.txt  out/output-main-n2-p2.txt

diff test/fixture/output-fifth-n2-p2.txt  out/output-fifth-n2-p2.txt

diff test/fixture/output-third-n2-p2.txt  out/output-third-n2-p2.txt

diff test/fixture/output-tuning-n2-p2.txt  out/output-tuning-n2-p2.txt
