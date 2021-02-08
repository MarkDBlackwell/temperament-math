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

diff out/output-2-2.txt  test/fixture/output-2-2.txt

diff out/output-fifth-2-2.txt  test/fixture/output-fifth-2-2.txt

diff out/output-third-2-2.txt  test/fixture/output-third-2-2.txt

diff out/output-tuning-2-2.txt  test/fixture/output-tuning-2-2.txt
