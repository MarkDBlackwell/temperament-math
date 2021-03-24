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

ruby -W lib/TemperamentMath/Calculate/calculate.rb 6 -6

diff test/fixture/main.txt        out/output-p6-n6-main.txt
diff test/fixture/thirdminor.txt  out/output-p6-n6-thirdminor.txt
diff test/fixture/third.txt       out/output-p6-n6-third.txt
diff test/fixture/fifth.txt       out/output-p6-n6-fifth.txt
diff test/fixture/tailored.txt    out/output-p6-n6-tailored.txt

ruby -W lib/TemperamentMath/Tuning/tuning.rb 4 [-1, 2, -1, 2, -1, 2, -2, 1, -2, 1, -2, 1] | diff test/fixture/tuning.txt -
