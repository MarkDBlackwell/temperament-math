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
  module Tuning

    extend self

    def deciles
      @@deciles ||= 11.times.to_a
    end

    def fifth_pure_alignment
      @@fifth_pure_alignment ||= 0.54321
    end

    def fifth_set
      @@fifth_set ||= begin
        cleaned = ARGV.drop(1).join(' ').delete ',[]'
        cleaned.split(' ').map &:to_i
      end
    end

    def fifth_set_valid?
      @@fifth_set_valid ||= begin
        true &&
            fifth_set.sum.zero? &&
            fifth_set.length == octave_size
      end
    end

    def octave_size
      12
    end

    def run_tuning
      unless fifth_set_valid?
        puts
        puts "Error: Invalid fifth set '#{fifth_set}'."
        return
      end
      unless third_major_flavor_strength_step_valid?
        puts
        puts "Error: Invalid flavor strength '#{third_major_flavor_strength_step}'."
        return
      end

      rounded = tuning_set.map{|e| e.round 5}
      puts "#{rounded} #{third_major_flavor_strength_step * 10}% #{fifth_pure_alignment.round 3}"
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
      @@third_major_flavor_strength_step ||= ARGV.first.to_i
    end

    def third_major_flavor_strength_step_valid?
      @@third_major_flavor_strength_step_valid ||= deciles.include? third_major_flavor_strength_step
    end

    def third_major_just_difference_cents
      @@third_major_just_difference_cents ||= begin
        equal_tempered = 400
        just_frequency_ratio = 5.0 / 4
        just_cents = (::Math.log2 just_frequency_ratio) * 1200
        (equal_tempered - just_cents).abs
      end
    end

    def third_major_size
      4
    end

    def third_major_target_cents
      @@third_major_target_cents ||= third_major_just_difference_cents * third_major_flavor_strength
    end

    def third_smallest_enum
      @@third_smallest_enum ||= third_major_size.times
    end

    def tuning_set
      @@tuning_set ||= begin
        stepwise_set.each_with_index.map do |deviation, note_index|
          offset = unit_cents * deviation
          equal_tempered = 100.0 * note_index.succ
          equal_tempered + offset
        end
      end
    end

    def unit_cents
      @@unit_cents ||= begin
        third_smallest = fifth_set.values_at(*third_smallest_enum).sum
        (third_major_target_cents / third_smallest).abs
      end
    end
  end
end

::TemperamentMath::Tuning.run_tuning
