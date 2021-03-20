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

    def build
      third_sets_build
      fifth_sets_build
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

    def fifth_extremes
      @@fifth_extremes ||= [fifth_min, fifth_max]
    end

    def fifth_large_enough_1(set)
      third_smallest_fifths_max(set) == set.at(0)
    end

    def fifth_max
      @@fifth_max ||= (2 != ARGV.length) ?  2 : ARGV.first.to_i
    end

    def fifth_min
      @@fifth_min ||= (2 != ARGV.length) ? -2 : ARGV.last.to_i
    end

    def fifth_range
      @@fifth_range ||= ::Range.new(*fifth_extremes)
    end

    def fifth_range_double
      @@fifth_range_double ||= ::Range.new(- fifth_span, fifth_span)
    end

    def fifth_range_prime?
      @@fifth_range_prime ||= begin
        clean = fifth_extremes.map &:abs
        pf = clean.map {|e| prime_factors e}
        pf.any? {|e| e.length <= 1}
      end
    end

    def fifth_range_tailored_construct(third_set)
      octave_enum.map do |offset|
        structure = fifth_range_tailored_structure.map do |index|
          (index + offset) % octave_size
        end
        a, b, c, d = third_set.values_at(*structure)
        smallest = [0, a - b, c - d].max + fifth_min
        largest  = [0, a - b, c - d].min + fifth_max
        ::Range.new smallest, largest
      end
    end

    def fifth_range_tailored_structure
      @@fifth_range_tailored_structure ||= [4, 5, 1, 12].map &:pred
    end

    def fifth_range_valid?
      @@fifth_range_valid ||= fifth_min.negative? && fifth_max.positive?
    end

    def fifth_set_save(set, third_set, tailored)
      return unless fifths_justified set
      return unless fifth_large_enough_1 set
      return unless fifth_similar_enough_2_3_4 set
      return unless fifth_small_enough_11_12 set
      return if fifths_are_a_multiple set
      minors = third_minor_set set
      return unless minors.uniq.length == octave_size
      return unless slope_good? minors, thirds_minor_half_top, thirds_minor_half_bottom
      third_set_write third_set, tailored
      @@fifth_sets_length += 1
      out_third_minor.puts "#{@@fifth_sets_length} #{minors}"
      out_third_minor.flush
      out_fifth.puts "#{@@fifth_sets_length} #{set}"
      out_fifth.flush
      nil
    end

    def fifth_sets_build
      @@third_sets_length = 0
      @@fifth_sets_length = 0
      out_third_raw.flush
      out_third_raw.rewind
      out_third_raw.each do |line|
        @@third_set_written = false
        fifth_set = ::Array.new octave_size
        all = line.split(' ').map &:to_i
##      key = all.first
        third_set = all.drop 1
        tailored = fifth_range_tailored_construct third_set
        group = [0, 4, 8]
        fifth_sets_build_1 fifth_set, third_set, tailored, group
      end
      nil
    end

    def fifth_sets_build_1(fifth_set, third_set, tailored, group)
# Pick a fifth; calculate two other fifths:
        i, j, k = transpose group, 0
        get(tailored, i).each do |f1|
          fifth_set[i] = f1
          fifth_set[j] = get(third_set, j) - get(third_set, j - 1) + get(fifth_set, i)
          fifth_set[k] = get(third_set, k) - get(third_set, k - 1) + get(fifth_set, j)
          next unless [j, k].all? {|m| get(tailored, m).include? get fifth_set, m}
          fifth_sets_build_2 fifth_set, third_set, tailored, group
        end
    end

    def fifth_sets_build_2(fifth_set, third_set, tailored, group)
# Pick a fifth; calculate two other fifths:
          i, j, k = transpose group, 1
          get(tailored, i).each do |f2|
            fifth_set[i] = f2
            fifth_set[j] = get(third_set, j) - get(third_set, j - 1) + get(fifth_set, i)
            fifth_set[k] = get(third_set, k) - get(third_set, k - 1) + get(fifth_set, j)
            next unless [j, k].all? {|m| get(tailored, m).include? get fifth_set, m}
            fifth_sets_build_3 fifth_set, third_set, tailored, group
      end
    end

    def fifth_sets_build_3(fifth_set, third_set, tailored, group)
# Pick a fifth; calculate two other fifths:
            i, j, k = transpose group, 2
            get(tailored, i).each do |f3|
              fifth_set[i] = f3
              fifth_set[j] = get(third_set, j) - get(third_set, j - 1) + get(fifth_set, i)
              fifth_set[k] = get(third_set, k) - get(third_set, k - 1) + get(fifth_set, j)
              next unless [j, k].all? {|m| get(tailored, m).include? get fifth_set, m}
              next unless fifth_sets_build_4 fifth_set, third_set, tailored, group
              next unless fifths_make_thirds fifth_set, third_set
              fifth_set_save fifth_set, third_set, tailored
            end
    end

    def fifth_sets_build_4(fifth_set, third_set, tailored, group)
# Calculate three fifths:
              i, j, k = transpose group, 3
              fifth_set[i] = get(third_set, i) - get(fifth_set, i - 1) - get(fifth_set, i - 2) - get(fifth_set, i - 3)
              fifth_set[j] = get(third_set, j) - get(third_set, j - 1) + get(fifth_set, i)
              fifth_set[k] = get(third_set, k) - get(third_set, k - 1) + get(fifth_set, j)
              [i, j, k].all? {|m| get(tailored, m).include? get fifth_set, m}
    end

    def fifth_similar_enough_2_3_4(set)
      values = set.values_at(*fifth_similar_enough_2_3_4_enum)
      variance = values.max - values.min
      variance <= fifth_similar_enough_2_3_4_target
    end

    def fifth_similar_enough_2_3_4_enum
      @@fifth_similar_enough_2_3_4_enum ||= third_smallest_enum.drop(1).to_enum
    end

    def fifth_similar_enough_2_3_4_target
      @@fifth_similar_enough_2_3_4_target ||= begin
        fraction = 0.2
        (fifth_min.abs * fraction).round.to_i
      end
    end

    def fifth_small_enough_11_12(set)
      minimum = third_largest_fifths_min set
      [10, 11].all? {|i| set.at(i) <= minimum}
    end

    def fifth_span
      @@fifth_span ||= (fifth_max - fifth_min).abs
    end

    def fifth_span_five
      @@fifth_span_five ||= fifth_span * 5
    end

    def fifth_span_four
      @@fifth_span_four ||= fifth_span * 4
    end

    def fifth_span_six
      @@fifth_span_six ||= fifth_span * 6
    end

    def fifth_span_three
      @@fifth_span_three ||= fifth_span * 3
    end

    def fifths_are_a_multiple(set)
      return false if fifth_range_prime?
      clean = set.map(&:abs).reject(&:zero?).uniq
      pf = clean.map {|e| prime_factors e}
      not pf.reduce(&:intersection).empty?
    end

    def fifths_justified(set)
      fifth_extremes.all? {|e| set.include? e}
    end

    def fifths_make_thirds(fifth_set, third_set)
      octave_enum.map do |falling|
        indexes = third_major_enum.map do |i|
          (falling - i) % octave_size
        end
        third_set.at(falling) == fifth_set.values_at(*indexes).sum
      end.all?
    end

    def get(array, index)
      array.at(index % octave_size)
    end

    def octave_enum
      @@octave_enum ||= octave_size.times
    end

    def octave_size
      12
    end

    def octave_size_half
      @@octave_size_half ||= octave_size / 2
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

    def out_fifth
      @@out_fifth ||= open 'fifth'
    end

    def out_tailored
      @@out_tailored ||= open 'tailored'
    end

    def out_third
      @@out_third ||= open 'third'
    end

    def out_third_minor
      @@out_third_minor ||= open 'thirdminor'
    end

    def out_third_raw
      @@out_third_raw ||= open 'third-raw'
    end

    def out_tuning
      @@out_tuning ||= open 'tuning'
    end

    def output_raw_delete
      @@output_raw.each do |filename, handle|
        handle.close
        ::File.delete filename
      end
      nil
    end

    def prime_factors(n)
      a = ::Prime.prime_division n
      return [] if a.empty?
      a.map &:first
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

    def run_calculate
      program_announce
      unless fifth_range_valid?
        puts
        puts "Error: Invalid fifth range: #{fifth_range}."
        return
      end
      out.puts "A range #{fifth_range} of fifths produces:"
      out.flush
      @@output_raw = []
      build
      output_raw_delete
      nil
    end

    def slope_good?(set, half_top, half_bottom)
      pair = 2
      triplet = 3
      polarities = [1, -1]
      polarities.zip([half_top, half_bottom]).flat_map do |polarity, half|
        set.values_at(*half).each_cons(triplet).map do |abc|
          pairs = abc.each_cons pair
          differences = pairs.map {|e| (e.first - e.last) * polarity}
          differences.first <= differences.last
        end
      end.all?
    end

    def third_build_1
      @@third_1 = - @@third_5  - @@third_9
      nil
    end

    def third_build_2
      @@third_2 = - @@third_10 - @@third_6
      nil
    end

    def third_build_7
      @@third_7 = - @@third_11 - @@third_3
      nil
    end

    def third_build_8
      @@third_8 = - @@third_4 - @@third_12
      nil
    end

    def third_key_build(set)
      0 # TODO
    end

    def third_largest_enum
      @@third_largest_enum ||= begin
        third_smallest_enum.map do |i|
          (i + octave_size_half) % octave_size
        end.to_enum
      end
    end

    def third_largest_fifths_min(set)
      set.values_at(*third_largest_enum).min
    end

    def third_major_enum
      @@third_major_enum ||= third_major_size.times
    end

    def third_major_size
      4
    end

    def third_max
      @@third_max ||= third_major_size * fifth_max
    end

    def third_min
      @@third_min ||= third_major_size * fifth_min
    end

    def third_minor_enum
      @@third_minor_enum ||= third_minor_size.times
    end

    def third_minor_set(fifth_set)
      octave_enum.map do |position|
        indexes = third_minor_set_indexes.at position
        - fifth_set.values_at(*indexes).sum
      end
    end

    def third_minor_set_indexes
# Circle of fifths: G D A E B F# C# G# D# A# F C
# Subtracting three fifths from C gives D# (for example).
      @@third_minor_set_indexes ||= begin
        octave_enum.map do |position|
          third_minor_enum.map do |i|
            (position.succ + i) % octave_size
          end
        end
      end
    end

    def third_minor_size
      3
    end

    def third_set_check(set)
      sums = octave_enum.map do |offset|
        structure = fifth_range_tailored_structure.map do |index|
          (index + offset) % octave_size
        end
# [4, 5, 1, 12]
        a, b, c, d = set.values_at(*structure)
        a + d - b - c
      end
      sums.all? {|e| fifth_range_double.include? e}
    end

    def third_set_check_5_6
      true &&
          @@third_2  >= [
              @@third_1 - fifth_span,
              2 * @@third_6 - @@third_3,
              ].max  &&
          @@third_7  >= [
              @@third_8 - fifth_span,
              2 * @@third_2 - @@third_6,
              ].max  &&
          @@third_8  >=  @@third_9  - fifth_span  &&
          @@third_1  >=  @@third_12 - fifth_span  &&

          @@third_8  <= [
              @@third_7 + fifth_span,
              2 * @@third_12 - @@third_9,
              ].min  &&
          @@third_1  <= [
              @@third_2 + fifth_span,
              2 * @@third_8 - @@third_12,
              ].min  &&
          @@third_2  <=  @@third_3  + fifth_span  &&
          @@third_7  <=  @@third_6  + fifth_span  &&
          third_set_check_5_part  &&
          third_set_check_6_part
    end

    def third_set_check_5_part
      difference_bottom = @@third_2  - @@third_6
      difference_top    = @@third_12 - @@third_8
      difference_max = [difference_bottom, difference_top].max
      difference_obligated = difference_bottom + difference_top + difference_max
      @@third_8 >= @@third_2 + difference_obligated
    end

    def third_set_check_6_part
      difference_bottom = @@third_7  - @@third_2
      difference_top    = @@third_8  - @@third_1
      difference_obligated = [difference_bottom, difference_top].max
      @@third_1 >= @@third_7 + difference_obligated
    end

    def third_set_save
      return unless third_set_check_5_6
      set = [
          @@third_1,  @@third_2,  @@third_3,  @@third_4,
          @@third_5,  @@third_6,  @@third_7,  @@third_8,
          @@third_9,  @@third_10, @@third_11, @@third_12,
          ]
      return unless slope_good? set, thirds_half_top, thirds_half_bottom
      return unless set.uniq.length == octave_size
      return unless third_set_check set
      key = third_key_build set
# Print thirds minimally before rewinding and filtering them, while building the fifth sets:
      out_third_raw.puts "#{key} #{set.join ' '}"
      nil
    end

    def third_set_write(set, tailored)
      unless @@third_set_written
        @@third_set_written = true
        @@third_sets_length += 1
        out_third.puts "#{@@third_sets_length} #{set}"
        out_third.flush
        out_tailored.puts "#{@@third_sets_length} #{tailored}"
        out_tailored.flush
        out_fifth.puts "(Makes third set #{@@third_sets_length}):"
        out_fifth.flush
      end
      nil
    end

    def third_sets_build
# Major thirds with levels:
#   1    2    3    4    5    6    6    5    4     3    2     1
#   n4 < n5 < n3 < n6 < n2 < n7 < n1 < n8 < n12 < n9 < n11 < n10
#   E    B    A    F#   D    C#   G    G#   C     D#   F     A#
#
      third_sets_build_level_1
      nil
    end

    def third_sets_build_level_1
# Walk disjointedly from both ends.
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_4,  third_edge_small = third_min, third_min
          @@third_10, third_edge_large = third_max, third_max
          break unless valid_level_1?
        when :small
          @@third_4 += 1
          unless valid_level_1?
            state = :large
            @@third_4 = third_edge_small
            third_edge_large -= 1
            @@third_10 = [
                third_edge_large,
                @@third_4 + fifth_span_six,
                ].min
            break unless valid_level_1?
          end
        when :large
          @@third_10 -= 1
          unless valid_level_1?
            state = :small
            @@third_10 = third_edge_large
            third_edge_small += 1
            @@third_4 = [
                third_edge_small,
                @@third_10 - fifth_span_six,
                ].max
            break unless valid_level_1?
          end
        end
        third_sets_build_level_2
      end
      nil
    end

    def third_sets_build_level_2
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_5,  third_edge_small = @@third_4  + 1, @@third_4  + 1
          @@third_11, third_edge_large = @@third_10 - 1, @@third_10 - 1
          break unless valid_level_2?
        when :small
          @@third_5 += 1
          unless valid_level_2?
            state = :large
            @@third_5 = third_edge_small
            third_edge_large -= 1
            @@third_11 = [
                third_edge_large,
                @@third_5 + fifth_span_six,
                @@third_4 + fifth_span_five,
                ].min
            break unless valid_level_2?
          end
        when :large
          @@third_11 -= 1
          unless valid_level_2?
            state = :small
            @@third_11 = third_edge_large
            third_edge_small += 1
            @@third_5 = [
                third_edge_small,
                @@third_11 - fifth_span_six,
                @@third_10 - fifth_span_five,
                ].max
            break unless valid_level_2?
          end
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
          start_bottom = 2 * @@third_5  - @@third_4
          start_top    = 2 * @@third_11 - @@third_10
          @@third_3, third_edge_small = start_bottom, start_bottom
          @@third_9, third_edge_large = start_top, start_top
          third_build_7
          third_build_1
          break unless valid_level_3_6?
        when :small
          @@third_3 += 1
          third_build_7
          unless valid_level_3_6?
            state = :large
            @@third_3 = third_edge_small
            third_build_7
            third_edge_large -= 1
            @@third_9 = [
                third_edge_large,
                @@third_3 + fifth_span_six,
                @@third_4 + fifth_span_five,
                @@third_5 + fifth_span_four,
                ].min
            third_build_1
            break unless valid_level_3_6?
          end
        when :large
          @@third_9 -= 1
          third_build_1
          unless valid_level_3_6?
            state = :small
            @@third_9 = third_edge_large
            third_build_1
            third_edge_small += 1
            @@third_3 = [
                third_edge_small,
                @@third_9  - fifth_span_six,
                @@third_10 - fifth_span_five,
                @@third_11 - fifth_span_four,
                ].max
            third_build_7
            break unless valid_level_3_6?
          end
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
          start_bottom = 2 * @@third_3 - @@third_5
          start_top    = 2 * @@third_9 - @@third_11
          @@third_6,  third_edge_small = start_bottom, start_bottom
          @@third_12, third_edge_large = start_top, start_top
          third_build_2
          third_build_8
# Levels 5 and 6 go in and out of validity.
          break unless valid_level_4_5?
        when :small
          @@third_6 += 1
          third_build_2
          unless valid_level_4_5?
            state = :large
            @@third_6 = third_edge_small
            third_build_2
            third_edge_large -= 1
            @@third_12 = [
                third_edge_large,
                @@third_6 + fifth_span_six,
                @@third_5 + fifth_span_five,
                @@third_4 + fifth_span_four,
                @@third_3 + fifth_span_three,
                ].min
            third_build_8
            break unless valid_level_4_5?
          end
        when :large
          @@third_12 -= 1
          third_build_8
          unless valid_level_4_5?
            state = :small
            @@third_12 = third_edge_large
            third_build_8
            third_edge_small += 1
            @@third_6 = [
                third_edge_small,
                @@third_12 - fifth_span_six,
                @@third_11 - fifth_span_five,
                @@third_10 - fifth_span_four,
                @@third_9  - fifth_span_three,
                ].max
            third_build_2
            break unless valid_level_4_5?
          end
        end
        third_set_save
      end
      nil
    end

    def third_smallest_enum
      @@third_smallest_enum ||= third_major_enum
    end

    def third_smallest_fifths_max(set)
      set.values_at(*third_smallest_enum).max
    end

    def third_span
      @@third_span ||= (third_max - third_min).abs
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

    def valid_level_1?
      @@third_10 >= @@third_4 + octave_size - 1
    end

    def valid_level_2?
      true &&
          @@third_11 >= @@third_10 - fifth_span  &&
          @@third_5  <= @@third_4  + fifth_span  &&
          valid_level_2_part?
    end

    def valid_level_2_part?
      difference_bottom = @@third_5  - @@third_4
      difference_top    = @@third_10 - @@third_11
      difference_max = [difference_bottom, difference_top].max
      difference_obligated = 4 * (difference_bottom + difference_top) + difference_max
      @@third_11 >= @@third_5 + difference_obligated
    end

    def valid_level_3_6?
      true &&
          @@third_9 >= [
             @@third_10 - fifth_span,
             (3 - @@third_5) / 2,
             ].max  &&
          @@third_3 <= [
             @@third_4 + fifth_span,
             (-3 - @@third_11) / 2,
             ].min  &&
          valid_level_3_part?
    end

    def valid_level_3_part?
      difference_bottom = @@third_3  - @@third_5
      difference_top    = @@third_11 - @@third_9
      difference_max = [difference_bottom, difference_top].max
      difference_obligated = 3 * (difference_bottom + difference_top) + difference_max
      @@third_9 >= @@third_3 + difference_obligated
    end

    def valid_level_4_5?
      true &&
          @@third_12 >= [
             @@third_11 - fifth_span,
             - @@third_4 - @@third_9 - fifth_span,
             - @@third_5 - @@third_9 - fifth_span,
             @@third_11 + @@third_3 - @@third_4 - fifth_span,
             (1 - @@third_4) / 2,
             ].max  &&
          @@third_6 <= [
             @@third_5 + fifth_span,
             - @@third_11 - @@third_3 + fifth_span,
             - @@third_10 - @@third_3 + fifth_span,
             - @@third_10 + @@third_5 + @@third_9 + fifth_span,
             (-1 - @@third_10) / 2,
             ].min  &&
          valid_level_4_part?
    end

    def valid_level_4_part?
      difference_bottom = @@third_6 - @@third_3
      difference_top    = @@third_9 - @@third_12
      difference_max = [difference_bottom, difference_top].max
      difference_obligated = 2 * (difference_bottom + difference_top) + difference_max
      @@third_12 >= @@third_6 + difference_obligated
    end
  end
end

::TemperamentMath::Calculate.run_calculate
