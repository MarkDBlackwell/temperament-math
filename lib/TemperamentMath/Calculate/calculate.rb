# coding: utf-8

=begin
Temperament-Math: calculate variegated circulating tuning temperaments
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
2021-Jan-14: created (mdb)
2021-Jan-26: works (mdb)
=end

require 'prime'

module TemperamentMath
  module Calculate
    extend self

    def arguments_valid?
      @@arguments_valid ||= 2 == ARGV.length
    end

    def delimit(n)
      n.to_s.gsub delimit_regexp, ','
    end

    def delimit_regexp
# See: http://www.programming-idioms.org/idiom/173/format-a-number-with-grouped-thousands/2430/ruby
#
# \b means: a word boundary.
# \B means: not a word boundary.
# (?=pattern) means: positive lookahead assertion.
#
# Assert there are (any number of) groups of three characters
# ending on a word boundary, and not beginning on a word boundary:
      @@delimit_regexp ||= ::Regexp.new( /\B(?=(...)*\b)/ )
    end

    def directory_output
      @@directory_output ||= "#{project_root}/out"
    end

    def fifth_build_5_12
      @@fifth_build_5_12 ||= begin
        @@fifth_5, @@fifth_6, @@fifth_7, @@fifth_8, @@fifth_9, @@fifth_10, @@fifth_11, @@fifth_12 =
            [2, 2, 1, 0, 0, 0, 2, 2].map {|e| fifth_max - e}
        'guard'
      end
    end

    def fifth_extremes
      @@fifth_extremes ||= [fifth_min, fifth_max]
    end

    def fifth_extremes_have_prime?
      @@fifth_extremes_have_prime ||= begin
        absolute = fifth_extremes.map &:abs
        factors = absolute.map {|e| prime_factors e}
        absolute.zip(factors).any? do |fifth, prime_list|
          [fifth] == prime_list
        end
      end
    end

    def fifth_max
      @@fifth_max ||= ARGV.first.to_i
    end

    def fifth_min
      @@fifth_min ||= ARGV.last.to_i
    end

    def fifth_range
      @@fifth_range ||= ::Range.new(*fifth_extremes)
    end

    def fifth_range_double
      @@fifth_range_double ||= ::Range.new(fifth_min - fifth_max, fifth_max - fifth_min)
    end

    def fifth_range_tailored_construct(third_set)
      fifth_range_tailored_structure_indexes.map do |structure|
        a, b, c, d = third_set.values_at(*structure)
        smallest = [0, a - b, c - d].max + fifth_min
        largest  = [0, a - b, c - d].min + fifth_max
        ::Range.new smallest, largest
      end
    end

    def fifth_range_tailored_offset_optimum(tailored)
      triplet = 3
      extra_length = triplet.pred
      sizes = tailored.map &:size
      padded = sizes + (sizes.take extra_length)
      indexed = padded.each_cons(triplet).each_with_index.map &:push
      indexed.sort.first.last
    end

    def fifth_range_tailored_structure
      @@fifth_range_tailored_structure ||= [4, 5, 1, 12].map &:pred
    end

    def fifth_range_tailored_structure_indexes
      @@fifth_range_tailored_structure_indexes ||= octave_enum.map do |index|
        fifth_range_tailored_structure.map do |offset|
          (index + offset) % octave_size
        end
      end
    end

    def fifth_range_valid?
      @@fifth_range_valid ||= begin
        true &&
            fifth_min.negative?  &&
            fifth_max.positive?  &&
            fifth_min.abs >= fifth_max
      end
    end

    def fifth_set_save(third_set, fifth_set)
      return unless fifths_justified? fifth_set
      return if fifths_are_a_multiple? fifth_set
      minors = third_minor_set fifth_set
      return unless minors.uniq.length == octave_size
      return unless slope_good? minors, thirds_minor_half_top, thirds_minor_half_bottom
      third_set_write third_set
      @@fifth_sets_length += 1
      out_third_minor.puts "#{@@fifth_sets_length} #{minors}"
      out_third_minor.flush
      out_fifth.puts "#{@@fifth_sets_length} #{fifth_set}"
      out_fifth.flush
      out_combined.puts "#{fifth_max}   #{fifth_min}   #{fifth_set}   #{third_set}"
      out_combined.flush
      @@solution_found = true
      nil
    end

    def fifth_sets_build(third_set)
      fifth_set = ::Array.new octave_size
      tailored = fifth_range_tailored_construct third_set
      offset = fifth_range_tailored_offset_optimum tailored
      level = 0
      fifth_sets_build_part level, offset, third_set, tailored, fifth_set
      nil
    end

    def fifth_sets_build_calculate(offset, third_set, tailored, fifth_set)
      i, j, k = transpose ring, offset + 3
# Calculate three fifths:
      fifth_set[i] = third_set.at(i) - get_in_circle(fifth_set, i - 1) - get_in_circle(fifth_set, i - 2) - get_in_circle(fifth_set, i - 3)
      fifth_set[j] = third_set.at(j) - get_in_circle(third_set, j - 1) + fifth_set.at(i)
      fifth_set[k] = third_set.at(k) - get_in_circle(third_set, k - 1) + fifth_set.at(j)
      [i, j, k].all? {|m| tailored.at(m).include? fifth_set.at m}
    end

    def fifth_sets_build_part(level, offset, third_set, tailored, fifth_set)
      i, j, k = transpose ring, offset + level
# Pick a fifth; calculate two other fifths:
      tailored.at(i).each do |fifth|
        fifth_set[i] = fifth
        fifth_set[j] = third_set.at(j) - get_in_circle(third_set, j - 1) + fifth_set.at(i)
        fifth_set[k] = third_set.at(k) - get_in_circle(third_set, k - 1) + fifth_set.at(j)
        next unless [j, k].all? {|m| tailored.at(m).include? fifth_set.at m}
        case level
        when 0, 1
          fifth_sets_build_part level + 1, offset, third_set, tailored, fifth_set
        when 2
          next unless fifth_sets_build_calculate offset, third_set, tailored, fifth_set
          next unless fifths_make_thirds? fifth_set, third_set
          fifth_set_save third_set, fifth_set
        else
          ::Kernel.fail
        end
      end
      nil
    end

    def fifth_sum_5_12
      @@fifth_sum_5_12 ||= [@@fifth_5, @@fifth_6, @@fifth_7, @@fifth_8, @@fifth_9, @@fifth_10, @@fifth_11, @@fifth_12].sum
    end

    def fifths_are_a_multiple?(fifth_set)
      return false if fifth_extremes_have_prime? # Elsewhere, the inclusion of fifth extremes is required.
      clean = fifth_set.map(&:abs).reject(&:zero?).uniq
      memo = prime_factors clean.first
      not clean.any? do |fifth|
        memo = memo.intersection(prime_factors fifth)
        memo.empty?
      end
    end

    def fifths_justified?(fifth_set)
      fifth_extremes.all? {|e| fifth_set.include? e}
    end

    def fifths_make_thirds?(fifth_set, third_set)
      third_set.each_with_index.all? do |third, i|
        indexes = fifths_make_thirds_indexes.at i
        fifth_set.values_at(*indexes).sum == third
      end
    end

    def fifths_make_thirds_indexes
      @@fifths_make_thirds_indexes ||= octave_enum.map do |highest|
        third_major_enum.map do |i|
          (highest - i) % octave_size
        end
      end
    end

    def get_in_circle(array, index)
      array.at(index % octave_size)
    end

    def octave_enum
      @@octave_enum ||= octave_size.times
    end

    def octave_size
      12
    end

    def open(name)
      is_raw = name.end_with? '-raw'
      mode = is_raw ? 'w+' : 'w'
      suffix = is_raw ? '' : '.txt'
      basename = "output-p#{fifth_max}-n#{-fifth_min}-#{name}#{suffix}"
      filename = "#{directory_output}/#{basename}"
      result = ::File.open filename, mode
      @@output_raw << [filename, result] if is_raw
      result
    end

    def out
      @@out ||= open 'main'
    end

    def out_combined
      @@out_combined ||= open 'combined'
    end

    def out_fifth
      @@out_fifth ||= open 'fifth'
    end

    def out_third
      @@out_third ||= open 'third'
    end

    def out_third_minor
      @@out_third_minor ||= open 'thirdminor'
    end

    def output_raw_delete
      @@output_raw.each do |filename, handle|
        handle.close
        begin
          ::File.delete filename
        rescue
        end
      end
      nil
    end

    def prime_factors(n)
      prime_factors_memo[n] # Method 'fetch' doesn't work, here.
    end

    def prime_factors_memo
      @@prime_factors_memo ||= ::Hash.new do |hash, key|
        a = ::Prime.prime_division key
        hash[key] = a.empty? ? a : (a.map &:first)
      end
    end

    def program_announce
      puts 'Temperament-Math: calculate'
      puts 'Copyright (C) 2021 Mark D. Blackwell.'
      puts 'This program comes with ABSOLUTELY NO WARRANTY; for details see the file, LICENSE.'
      puts 'Output is in directory, "out/"'
      nil
    end

    def project_root
      @@project_root ||= ::File.dirname ::File.realpath "#{__FILE__}/../../.."
    end

    def report
      out.puts
      out.puts "* #{delimit @@third_sets_length} sets of thirds, falling from"
      out.puts '      G D A E B F# C# G# D# A# F C'
      return if @@third_sets_length.zero?

      out.flush
      out.puts
      out.puts "* #{delimit @@fifth_sets_length} sets of fifths, also falling from"
      out.puts '      G D A E B F# C# G# D# A# F C'
      return if @@fifth_sets_length.zero?

      out.flush
      out.puts
      out.puts '* And corresponding tuning sets, indicating the positions of'
      out.puts '      C# D D# E F F# G G# A A# B C'
      nil
    end

    def ring
      @@ring ||= [0, 4, 8]
    end

    def run_calculate
      program_announce
      unless arguments_valid?
        puts
        puts "Error: Invalid arguments: \`#{ARGV.join ' '}'."
        return
      end
      unless fifth_range_valid?
        puts
        puts "Error: Invalid fifth range: #{fifth_range}."
        return
      end
      @@solution_found = false
      out.puts "A range #{fifth_range} of fifths produces:"
      out.flush
      third_sets_build
      report
      ::Kernel.exit 1 unless @@solution_found
      nil
    end

    def slope_good?(set, half_top, half_bottom)
      pair = 2
      triplet = 3
      polarities = [1, -1]
      polarities.zip([half_top, half_bottom]).all? do |polarity, half|
        set.values_at(*half).each_cons(triplet).all? do |abc|
          pairs = abc.each_cons pair
          differences = pairs.map {|e| (e.first - e.last) * polarity}
          differences.first <= differences.last
        end
      end
    end

# Fixed: f5 through f12; n8 through n12; and n4.
# U=unused; H=have
#   H   @@fifth_1  - @@fifth_9  == @@third_1  - @@third_12
#   H   @@fifth_2  - @@fifth_10 == @@third_2  - @@third_1
# U     @@fifth_3  - @@fifth_11 == @@third_3  - @@third_2
#   H   @@fifth_4  - @@fifth_12 == @@third_4  - @@third_3
# U     @@fifth_5  - @@fifth_1  == @@third_5  - @@third_4
# U     @@fifth_6  - @@fifth_2  == @@third_6  - @@third_5
#   H   @@fifth_7  - @@fifth_3  == @@third_7  - @@third_6
# U     @@fifth_8  - @@fifth_4  == @@third_8  - @@third_7
# U     @@fifth_9  - @@fifth_5  == @@third_9  - @@third_8
# U     @@fifth_10 - @@fifth_6  == @@third_10 - @@third_9
# U     @@fifth_11 - @@fifth_7  == @@third_11 - @@third_10
# U     @@fifth_12 - @@fifth_8  == @@third_12 - @@third_11
    def third_build_1_from_5
# Level 6 from 2:
      @@third_1 = - @@third_5 - 4 * fifth_max + 3
      @@fifth_1 = @@third_1 + @@fifth_9 - 4 * fifth_max + 4
      nil
    end

    def third_build_2_from_6
# Level 5 from 4:
      @@third_2 = - @@third_6 - 4 * fifth_max + 1
      @@fifth_2 = @@third_2 - @@third_1 + @@fifth_10
      @@fifth_3 = @@third_6 - @@third_7 + @@fifth_7
      nil
    end

    def third_build_7_from_3
# Level 6 from 3:
      @@third_7 = - @@third_3 - 4 * fifth_max + 2
      @@fifth_4 = - @@third_3 + @@fifth_12 - 8 * fifth_max + 9
      nil
    end

    def third_cap_5
      @@third_cap_5 ||= (fifth_min * 2.4).round
    end

    def third_major_enum
      @@third_major_enum ||= third_major_size.times
    end

    def third_major_size
      4
    end

    def third_max_1
      @@third_max_1 ||= 3 * fifth_max + fifth_min - 4
    end

    def third_max_3
      @@third_max_3 ||= [
          - 7 * fifth_max - fifth_min + 9,
          - (4 * fifth_max + 1) / 2,
          ].min
    end

    def third_max_5
      @@third_max_5 ||= [
          - 7 * fifth_max - fifth_min + 9,
          - 6 * fifth_max + 6,
          third_cap_5,
          ].min
    end

    def third_minor_enum
      @@third_minor_enum ||= third_minor_size.times
    end

    def third_minor_set(fifth_set)
      third_minor_set_indexes.map do |indexes|
        - fifth_set.values_at(*indexes).sum
      end
    end

    def third_minor_set_indexes
# Circle of fifths: G D A E B F# C# G# D# A# F C
# Subtracting three fifths from C gives D# (for example).
      @@third_minor_set_indexes ||= octave_enum.map do |position|
        third_minor_enum.map do |i|
          (position.succ + i) % octave_size
        end
      end
    end

    def third_minor_size
      3
    end

    def third_set_check(third_set)
# [4, 5, 1, 12]
      fifth_range_tailored_structure_indexes.each_with_index.all? do |structure, index|
        a, b, c, d = third_set.values_at(*structure)
        sum = a + d - b - c
        fifth_range_double.include? sum
      end
    end

    def third_set_check_5_6
      true &&
          [@@fifth_1, @@fifth_2, @@fifth_3, @@fifth_4, fifth_sum_5_12].sum.zero?  &&
          @@third_2 >= 2 * @@third_6 - @@third_3  &&
          @@third_7 >= [
              2 * @@third_2 - @@third_6,
              3 * fifth_max + fifth_min - 5,
              ].max  &&
          @@third_1 >= third_max_1  &&

          @@third_2 <= [
              @@third_3 + fifth_max - fifth_min,
              (2 * @@third_6 + 4 * fifth_max) / 3 - 2,
              ].min  &&
          @@third_7 <= @@third_6 + fifth_max - fifth_min  &&
          @@third_1 <= [
              @@third_2 + fifth_max - fifth_min,
              4 * fifth_max - 6,
              ].min  &&
          third_set_check_6_part
    end

    def third_set_check_6_part
      difference_bottom = @@third_7 - @@third_2
      difference_top    = - @@third_1 + 4 * fifth_max - 5
      difference_obligated = [difference_bottom, difference_top].max
      @@third_1 >= @@third_7 + difference_obligated
    end

    def third_set_check_fifth_sets_build
      return unless third_set_check_5_6
      four = 4 * fifth_max
      third_set = [
          @@third_1,  @@third_2,  @@third_3, - 8 * fifth_max + 9,
          @@third_5,  @@third_6,  @@third_7, four - 5,
          four - 3, four - 1, four - 2, four - 4,
          ]
      return unless slope_good? third_set, thirds_half_top, thirds_half_bottom
      return unless third_set.uniq.length == octave_size
      return unless third_set_check third_set
      @@third_set_written = false
      fifth_sets_build third_set
      nil
    end

    def third_set_write(third_set)
      unless @@third_set_written
        @@third_set_written = true
        @@third_sets_length += 1
        out_third.puts "#{@@third_sets_length} #{third_set}"
        out_third.flush
        out_fifth.puts "(Makes third set #{@@third_sets_length}):"
        out_fifth.flush
      end
      nil
    end

    def third_sets_build
      @@output_raw = []
      @@third_sets_length = 0
      @@fifth_sets_length = 0
# Major thirds with levels:
#   1    2    3    4    5    6    6    5    4     3    2     1
#   n4 < n5 < n3 < n6 < n2 < n7 < n1 < n8 < n12 < n9 < n11 < n10
#   E    B    A    F#   D    C#   G    G#   C     D#   F     A#
#
      fifth_build_5_12
      third_sets_build_level_2
      output_raw_delete
      nil
    end

    def third_sets_build_level_2
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_5 = - 8 * fifth_max + 10
          third_build_1_from_5
          break unless valid_level_2?
        when :small
          @@third_5 += 1
          third_build_1_from_5
          break unless valid_level_2?
        end
        third_sets_build_level_3_6
      end
      nil
    end

    def third_sets_build_level_3_6
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_3 = 2 * @@third_5 + 8 * fifth_max - 9
          third_build_7_from_3
          break unless valid_level_3_6?
        when :small
          @@third_3 += 1
          third_build_7_from_3
          break unless valid_level_3_6?
        end
        third_sets_build_level_4_5
      end
      nil
    end

    def third_sets_build_level_4_5
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_6 = 2 * @@third_3 - @@third_5
          third_build_2_from_6
# Levels 5 and 6 go in and out of validity.
          break unless valid_level_4_5?
        when :small
          @@third_6 += 1
          third_build_2_from_6
          break unless valid_level_4_5?
        end
        third_set_check_fifth_sets_build
      end
      nil
    end

    def third_span
      @@third_span ||= third_major_size * (fifth_max - fifth_min)
    end

    def thirds_half_bottom
# An example set of good major thirds is:
# [2,  -5,  -10, -13, -12, -8,  -2,   5,   10,  13,  12,  8]
#  G    D    A    E    B    F#   C#   G#   D#   A#   F    C
#  1    2    3    4    5    6    7    8    9    10   11   12
#
      @@thirds_half_bottom ||= [4, 5, 3, 6, 2, 7, 1].map &:pred
    end

    def thirds_half_top
      @@thirds_half_top ||= [10, 11, 9, 12, 8, 1, 7].map &:pred
    end

    def thirds_minor_half_bottom
# An example set of good minor thirds is:
# [13,  10,  5,  -2,  -8,  -12, -13, -10, -5,   2,   8,   12]
#  G    D    A    E    B    F#   C#   G#   D#   A#   F    C
#  1    2    3    4    5    6    7    8    9    10   11   12
#
      @@thirds_minor_half_bottom ||= [7, 6, 8, 5, 9, 4, 10].map &:pred
    end

    def thirds_minor_half_top
      @@thirds_minor_half_top ||= [1, 12, 2, 11, 3, 10, 4].map &:pred
    end

    def transpose(indexes, offset)
      indexes.map do |i|
        (i + offset) % octave_size
      end
    end

    def valid_level_2?
      @@third_5 <= third_max_5
    end

    def valid_level_3_6?
      @@third_3 <= [
          (@@third_5 + fifth_max + 1) * 4 / 5 - 2,
          third_max_3,
          ].min
    end

    def valid_level_4_5?
      @@third_6 <= [
          @@third_5 + fifth_max - fifth_min - 2,
          - @@third_3 - 3 * fifth_max - fifth_min + 1,
          (3 * @@third_3 + 2) / 4 + fifth_max - 2,
          - 2 * fifth_max,
          ].min
    end
  end
end

::TemperamentMath::Calculate.run_calculate
