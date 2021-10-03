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
=end

module TemperamentMath
  module Tuning2

    extend self

    def deciles
      @@deciles ||= 11.times.to_a
    end

    def eccentricity_c_e
      @@eccentricity_c_e ||= begin
        pure_major_third = 5 / 4.0
        logarithm_c_e = (::Math.log2 pure_major_third) * 1200
        logarithm_c_e - 400
      end
    end

    def eccentricity_fifth_c_g
      @@eccentricity_fifth_c_g ||= fifth_c_g - 700
    end

    def fifth_c_g
      @@fifth_c_g ||= ARGV.at(1).to_f
    end

    def fifth_set
      @@fifth_set ||= begin
        three = (eccentricity_c_e - eccentricity_fifth_c_g) / 3
        eight = - eccentricity_c_e / 8
        [eccentricity_fifth_c_g] + [three] * 3 + [eight] * 8
      end
    end

    def run_tuning2
      unless 2 == ARGV.length
        puts
        puts "Error: two arguments are required."
        return
      end
      unless third_major_flavor_strength_step_valid?
        puts
        puts "Error: Invalid flavor strength '#{third_major_flavor_strength_step}'."
        return
      end

      rounded = tuning_set.map{|e| e.round 5}
      puts "#{rounded} #{third_major_flavor_strength_step * 10}% #{fifth_c_g}"
      nil
    end

    def stepwise
# "Falling from G#" here (for example) equals "rising from C#" in most
# outside-world documentation and programs, such as Scala.
# The circle of fifths (except for C):
# 1  2  3  4  5  6  7  8  9  10 11
# G  D  A  E  B  F# C# G# D# A# F
#
#       Position of:  C#  D  D#  E  F   F#  G  G#  A  A#  B
      @@stepwise ||= [7,  2, 9,  4, 11, 6,  1, 8,  3, 10, 5].map &:pred
    end

    def stepwise_set
      @@stepwise_set ||= begin
        sum = 0
        accumulated_set = fifth_set.map{|e| sum += e}
        accumulated_set.values_at(*stepwise)
      end
    end

    def third_major_flavor_strength
      @@third_major_flavor_strength ||= third_major_flavor_strength_step / 10.0
    end

    def third_major_flavor_strength_step
      @@third_major_flavor_strength_step ||= ARGV.at(0).to_i
    end

    def third_major_flavor_strength_step_valid?
      @@third_major_flavor_strength_step_valid ||= deciles.include? third_major_flavor_strength_step
    end

    def tuning_set
      @@tuning_set ||= begin
        stepwise_set.each_with_index.map do |deviation, note_index|
          offset = third_major_flavor_strength * deviation
          equal_tempered = 100.0 * note_index.succ
          equal_tempered + offset
        end
      end
    end
  end
end

::TemperamentMath::Tuning2.run_tuning2
