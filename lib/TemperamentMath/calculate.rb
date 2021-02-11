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

module TemperamentMath
  extend self

  def build
    third_sets_build
    fifth_sets_build
    out.puts
    out.puts "* #{delimit @@third_sets_raw_length} sets of thirds, rising to"
    out.puts '      G D A E B F# C# G# D# A# F C'
    return if @@third_sets_raw_length.zero?
    out.puts
    out.puts "* #{delimit @@fifth_sets_length} sets of fifths, also rising to"
    out.puts '      G D A E B F# C# G# D# A# F C'
    return if @@fifth_sets_length.zero?

    tuning_sets_build
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
    @@delimit_regexp ||= ::Regexp.new(/\B(?=(...)*\b)/)
  end

  def directory_output
    @@directory_output ||= "#{project_root}/out"
  end

  def fifth_large_enough_1(set)
    @@fifth_1 >= (third_smallest_fifths_max set)
  end

  def fifth_max
    2
  end

  def fifth_min
    -2
  end

  def fifth_range
    @@fifth_range ||= fifth_min..fifth_max
  end

  def fifth_range_valid?
    fifth_min.negative? && fifth_max.positive?
  end

  def fifth_set_save
    set = [
        @@fifth_1,  @@fifth_2,  @@fifth_3,  @@fifth_4,
        @@fifth_5,  @@fifth_6,  @@fifth_7,  @@fifth_8,
        @@fifth_9,  @@fifth_10, @@fifth_11, @@fifth_12,
        ]
    return unless fifths_justified set
    return unless fifth_large_enough_1 set
    return unless fifth_small_enough_11_12 set
    return unless third_minor_set_good? set
    unless @@third_indicated
      @@third_indicated = true
      out_fifth.puts "Third set #{@@third_sets_length}:"
    end
    out_fifth_raw.print "#{set.join ' '}\n"
    out_fifth.puts "#{@@fifth_sets_length} #{set}"
    nil
  end

  def fifth_sets_build
    @@third_sets_length = 0
    @@fifth_sets_length = 0
    out_third_raw.rewind
    out_third_raw.each_with_index do |line, index|
      third_set = line.split(' ').map &:to_i
      if true
        @@third_sets_length += 1
        out_third.puts "#{@@third_sets_length} #{third_set}"
        @@third_indicated = false
      end
      @@third_1,  @@third_2,  @@third_3,  @@third_4,
      @@third_5,  @@third_6,  @@third_7,  @@third_8,
      @@third_9,  @@third_10, @@third_11, @@third_12 = third_set
# Pick a fifth; calculate two other fifths:
      fifth_range.each do |f1|
        @@fifth_1 = f1
        @@fifth_5 = @@third_5 - @@third_4 + @@fifth_1
        @@fifth_9 = @@third_9 - @@third_8 + @@fifth_5
        next unless [@@fifth_5, @@fifth_9].all? {|e| fifth_range.include? e}
# Pick a fifth; calculate two other fifths:
        fifth_range.each do |f2|
          @@fifth_2 = f2
          @@fifth_6  = @@third_6 - @@third_5 + @@fifth_2
          @@fifth_10 = @@third_10 - @@third_9 + @@fifth_6
          next unless [@@fifth_6, @@fifth_10].all? {|e| fifth_range.include? e}
# Pick a fifth; calculate two other fifths:
          fifth_range.each do |f3|
            @@fifth_3 = f3
            @@fifth_7  = @@third_7 - @@third_6 + @@fifth_3
            @@fifth_11 = @@third_11 - @@third_10 + @@fifth_7
            next unless [@@fifth_7, @@fifth_11].all? {|e| fifth_range.include? e}
# Calculate three fifths:
            @@fifth_4  = @@third_4 - @@fifth_1 - @@fifth_2 - @@fifth_3
            @@fifth_8  = @@third_8 - @@third_7 + @@fifth_4
            @@fifth_12 = @@third_12 - @@third_11 + @@fifth_8
            next unless [@@fifth_4, @@fifth_8, @@fifth_12].all? {|e| fifth_range.include? e}
            next unless true &&
                @@fifth_10 + @@fifth_11 + @@fifth_12 + @@fifth_1  == @@third_1   &&
                @@fifth_11 + @@fifth_12 + @@fifth_1  + @@fifth_2  == @@third_2   &&
                @@fifth_12 + @@fifth_1  + @@fifth_2  + @@fifth_3  == @@third_3   &&
                @@fifth_2  + @@fifth_3  + @@fifth_4  + @@fifth_5  == @@third_5   &&
                @@fifth_3  + @@fifth_4  + @@fifth_5  + @@fifth_6  == @@third_6   &&
                @@fifth_4  + @@fifth_5  + @@fifth_6  + @@fifth_7  == @@third_7   &&
                @@fifth_5  + @@fifth_6  + @@fifth_7  + @@fifth_8  == @@third_8   &&
                @@fifth_6  + @@fifth_7  + @@fifth_8  + @@fifth_9  == @@third_9   &&
                @@fifth_7  + @@fifth_8  + @@fifth_9  + @@fifth_10 == @@third_10  &&
                @@fifth_8  + @@fifth_9  + @@fifth_10 + @@fifth_11 == @@third_11  &&
                @@fifth_9  + @@fifth_10 + @@fifth_11 + @@fifth_12 == @@third_12
            fifth_set_save
          end
        end
      end
    end
    nil
  end

  def fifth_small_enough_11_12(set)
    [@@fifth_11, @@fifth_12].all? do |e|
      e <= (third_largest_fifths_min set)
    end
  end

  def fifth_span
    @@fifth_span ||= fifth_max - fifth_min
  end

  def fifths_justified(set)
    [fifth_min, fifth_max].all? {|extreme| set.include? extreme}
  end

  def octave_size
    12
  end

  def octave_size_half
    @@octave_size_half ||= octave_size / 2
  end

  def open(name, bidirectional=false)
    mode = bidirectional ? 'w+' : 'w'
    is_raw = name.end_with? '-raw'
    suffix = is_raw ? '' : '.txt'
    basename = "#{name}-n#{-fifth_min}-p#{fifth_max}#{suffix}"
    filename = "#{directory_output}/#{basename}"
    result = ::File.open filename, mode
    @@output_raw << [filename, result] if is_raw
    result
  end

  def out
    @@out ||= open 'output-main'
  end

  def out_fifth
    @@out_fifth ||= open 'output-fifth'
  end

  def out_fifth_raw
    @@out_fifth_raw ||= open 'output-fifth-raw', true
  end

  def out_third
    @@out_third ||= open 'output-third'
  end

  def out_third_minor
    @@out_third_minor ||= open 'output-third-minor'
  end

  def out_third_raw
    @@out_third_raw ||= open 'output-third-raw', true
  end

  def out_tuning
    @@out_tuning ||= open 'output-tuning'
  end

  def output_raw_delete
    @@output_raw.each do |filename, handle|
      handle.close
      ::File.delete filename
    end
    nil
  end

  def program_announce
    puts 'Temperament-Math'
    puts 'Copyright (C) 2021 Mark D. Blackwell.'
    puts 'This program comes with ABSOLUTELY NO WARRANTY; for details see the file, LICENSE.'
    puts 'Output is in directory, "out/"'
    nil
  end

  def project_root
    @@project_root ||= ::File.dirname ::File.realpath "#{__FILE__}/../.."
  end

  def run
    program_announce
    unless fifth_range_valid?
      puts
      puts "Error: Invalid fifth range: #{fifth_range}."
      return
    end
    out.puts "A range #{fifth_range} of fifths produces:"
    @@output_raw = []
    build
    output_raw_delete
    nil
  end

  def slope_good?(set, half_top, half_bottom)
    triplet = 3
    [half_top, half_bottom].flat_map do |half|
      set.values_at(*half).each_cons(triplet).map do |a, b, c|
        (a - b).abs <= (b - c).abs
      end
    end.all?
  end

  def stepwise
# "Rising to G#" here (for example) equals "rising from C#" in most
# outside-world documentation and programs, such as Scala.
# The circle of fifths (except for C):
# 1  2  3  4  5  6  7  8  9  10 11
# G  D  A  E  B  F# C# G# D# A# F
#
#     Position of:  C#  D  D#  E  F   F#  G  G#  A  A#  B
    @@stepwise ||= [7,  2, 9,  4, 11, 6,  1, 8,  3, 10, 5].map &:pred
  end

  def third_largest_enum
    @@third_largest_enum ||= begin
      third_smallest_enum.map do |i|
        i + octave_size_half
      end.to_enum
    end
  end

  def third_largest_fifths_min(set)
    third_largest_enum.map{|i| set.at i}.min
  end

  def third_major_just_difference_cents
    @@third_major_just_difference_cents ||= begin
      equal_tempered = 400
      just_frequency_ratio = 5.0 / 4
      just_cents = (Math.log2 just_frequency_ratio) * 1200
      (equal_tempered - just_cents).abs
    end
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

  def third_minor_set(fifth_set)
# Circle of fifths: G D A E B F# C# G# D# A# F C
# Subtracting three fifths from C gives D# (for example).
    octave_size.times.map do |position|
      indexes = third_minor_size.times.map do |i|
        (position.succ + i) % octave_size
      end
      - fifth_set.values_at(*indexes).sum
    end
  end

  def third_minor_set_good?(fifth_set)
    result = 'good'
    set = third_minor_set fifth_set
    return unless slope_good? set, thirds_minor_half_top, thirds_minor_half_bottom
    @@fifth_sets_length += 1
    out_third_minor.puts "#{@@fifth_sets_length} #{set}"
    result
  end

  def third_minor_size
    3
  end

  def third_set_save
    set = [
        @@third_1,  @@third_2,  @@third_3,  @@third_4,
        @@third_5,  @@third_6,  @@third_7,  @@third_8,
        @@third_9,  @@third_10, @@third_11, @@third_12,
        ]
    return unless slope_good? set, thirds_half_top, thirds_half_bottom
    @@third_sets_raw_length += 1
    out_third_raw.print "#{set.join ' '}\n"
    nil
  end

  def third_sets_build
    @@third_sets_raw_length = 0
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
        @@third_4,  third_edge_4  = third_min, third_min
        @@third_10, third_edge_10 = third_max, third_max
        break unless valid_level_1?
      when :small
        @@third_4 += 1
        unless valid_level_1?
          state = :large
          @@third_4 = third_edge_4
          third_edge_10 -= 1
          @@third_10 = third_edge_10
          break unless valid_level_1?
        end
      when :large
        @@third_10 -= 1
        unless valid_level_1?
          state = :small
          @@third_10 = third_edge_10
          third_edge_4 += 1
          @@third_4 = third_edge_4
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
        @@third_5,  third_edge_5  = @@third_4  + 1, @@third_4  + 1
        @@third_11, third_edge_11 = @@third_10 - 1, @@third_10 - 1
        break unless valid_level_2?
      when :small
        @@third_5 += 1
        unless valid_level_2?
          state = :large
          @@third_5 = third_edge_5
          third_edge_11 -= 1
          @@third_11 = third_edge_11
          break unless valid_level_2?
        end
      when :large
        @@third_11 -= 1
        unless valid_level_2?
          state = :small
          @@third_11 = third_edge_11
          third_edge_5 += 1
          @@third_5 = third_edge_5
          break unless valid_level_2?
        end
      end
      third_sets_build_level_3
    end
    nil
  end

  def third_sets_build_level_3
    state = :initial
    while true
      case state
      when :initial
        state = :small
        @@third_3, third_edge_3 = @@third_5  + 1, @@third_5  + 1
        @@third_9, third_edge_9 = @@third_11 - 1, @@third_11 - 1
        break unless valid_level_3?
      when :small
        @@third_3 += 1
        unless valid_level_3?
          state = :large
          @@third_3 = third_edge_3
          third_edge_9 -= 1
          @@third_9 = third_edge_9
          break unless valid_level_3?
        end
      when :large
        @@third_9 -= 1
        unless valid_level_3?
          state = :small
          @@third_9 = third_edge_9
          third_edge_3 += 1
          @@third_3 = third_edge_3
          break unless valid_level_3?
        end
      end
      third_sets_build_level_4
    end
    nil
  end

  def third_sets_build_level_4
    state = :initial
    while true
      case state
      when :initial
        state = :small
        @@third_6,  third_edge_6  = @@third_3 + 1, @@third_3 + 1
        @@third_12, third_edge_12 = @@third_9 - 1, @@third_9 - 1
        break unless valid_level_4?
      when :small
        @@third_6 += 1
        unless valid_level_4?
          state = :large
          @@third_6 = third_edge_6
          third_edge_12 -= 1
          @@third_12 = third_edge_12
          break unless valid_level_4?
        end
      when :large
        @@third_12 -= 1
        unless valid_level_4?
          state = :small
          @@third_12 = third_edge_12
          third_edge_6 += 1
          @@third_6 = third_edge_6
          break unless valid_level_4?
        end
      end
      third_sets_build_level_5_6
    end
    nil
  end

  def third_sets_build_level_5_6
    @@third_1 = - @@third_5 - @@third_9
    @@third_2 = - @@third_6 - @@third_10
    @@third_7 = - @@third_3 - @@third_11
    @@third_8 = - @@third_4 - @@third_12
    third_set_save if valid_level_5_6?
    nil
  end

  def third_smallest_enum
    @@third_smallest_enum ||= third_major_size.times
  end

  def third_smallest_fifths_max(set)
    third_smallest_enum.map{|i| set.at i}.max
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

  def tuning_sets_build
    out_fifth_raw.rewind
    out_fifth_raw.each_with_index do |line, index|
      fifth_set = line.split(' ').map &:to_i
      third_smallest = fifth_set.values_at(*third_smallest_enum).sum
      unit = (third_major_just_difference_cents / third_smallest).abs
      sum = 0
      accumulated_set = fifth_set.map{|e| sum += e}
      stepwise_set = accumulated_set.values_at(*stepwise)
      tuning_set = stepwise_set.each_with_index.map do |deviation, note_index|
        offset = unit * deviation
        equal_tempered = 100.0 * note_index.succ
        equal_tempered + offset
      end
      out_tuning.puts "#{index + 1} #{tuning_set.map{|e| e.round 5}}"
    end
    nil
  end

  def valid_level_1?
    @@third_10 >= @@third_4 + octave_size - 1
  end

  def valid_level_2?
    true &&
        @@third_11 >= [@@third_10 - fifth_span, @@third_5 + octave_size - 3].max  &&
        @@third_5  <=  @@third_4  + fifth_span
  end

  def valid_level_3?
    true &&
        @@third_9  >= [@@third_10 - fifth_span, (  3 - @@third_5 ) / 2, @@third_3 + octave_size - 5].max  &&
        @@third_3  <= [@@third_4  + fifth_span, (- 3 - @@third_11) / 2].min
  end

  def valid_level_4?
    true &&
        @@third_12 >= [@@third_11 - fifth_span, (  1 - @@third_4 ) / 2, @@third_6 + octave_size - 7].max  &&
        @@third_6  <= [@@third_5  + fifth_span, (- 1 - @@third_10) / 2].min
  end

  def valid_level_5_6?
    true &&
        @@third_2 >= [@@third_1  - fifth_span, @@third_6  + 1].max  &&
        @@third_7 >= [@@third_8  - fifth_span, @@third_2  + 1].max  &&
        @@third_1 >= [@@third_12 - fifth_span, @@third_7  + 1].max  &&
        @@third_8 >= [@@third_9  - fifth_span, @@third_1  + 1].max  &&

        @@third_2 <=  @@third_3  + fifth_span  &&
        @@third_7 <=  @@third_6  + fifth_span  &&
        @@third_1 <=  @@third_2  + fifth_span  &&
        @@third_8 <= [@@third_7  + fifth_span, @@third_12 - 1].min
  end
end

TemperamentMath::run
