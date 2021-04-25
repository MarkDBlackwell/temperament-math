# coding: utf-8

=begin
Copyright (C) 2021 Mark D. Blackwell.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Contact: Mark D. Blackwell
markdblackwell01@gmail.com

Author: Mark D. Blackwell
Dates:
=end

module TemperamentMath
  module Ratio
    extend self

    def fifth_extremes(filename)
      fifth_extremes_regexp.match(filename).captures
    end

    def fifth_extremes_regexp
      @@fifth_extremes_regexp ||= ::Regexp.new( /-p(\d+)-n(\d+)-/ )
    end

    def run_ratio
      ARGV.each do |filename|
        fifth_max, fifth_min = fifth_extremes filename
        ratio = fifth_min.to_i.to_f / fifth_max.to_i.to_f
        puts "#{ratio.round 4}  :  #{fifth_max}  #{fifth_min}"
      end
      nil
    end
  end
end

::TemperamentMath::Ratio.run_ratio
