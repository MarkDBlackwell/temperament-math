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

  def directory_output
    @@directory_output ||= "#{project_root}/out"
  end

  def fifth_accumulated_sets_build
    out_fifth_raw.rewind
    out_fifth_raw.each_with_index do |line, index|
      fifth_set = line.split(' ').map &:to_i
      sum = 0
      set = fifth_set.map{|e| sum += e}
      out_accumulated_raw.print "#{set.join ' '}\n"
      out_accumulated.puts "#{index + 1} #{set}"
    end
    nil
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

  def fifth_set_save
    set = [
        @@fifth_1,  @@fifth_2,  @@fifth_3,  @@fifth_4,
        @@fifth_5,  @@fifth_6,  @@fifth_7,  @@fifth_8,
        @@fifth_9,  @@fifth_10, @@fifth_11, @@fifth_12,
        ]
    @@fifth_sets_length += 1
    out_fifth_raw.print "#{set.join ' '}\n"
    out_fifth.puts "#{@@fifth_sets_length} #{set}"
    nil
  end

  def fifth_sets_build
    @@fifth_sets_length = 0
    out_third_raw.rewind
    out_third_raw.each_with_index do |line, index|
      out_fifth.puts "Third set #{index + 1}:"
      third_set = line.split(' ').map &:to_i
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

  def fifth_span
    @@fifth_span ||= fifth_max - fifth_min
  end

  def fifth_stepwise_sets_build
# "Rising to G#" here (for example) usually equals "rising from C#" in the outside world.
# 0  1  2  3  4  5  6  7  8  9  10 11
# G  D  A  E  B  F# C# G# D# A# F  C
# Position of:  C#  D  D#  E  F   F#  G  G#  A  A#  B  C
    stepwise = [6,  1, 8,  3, 10, 5,  0, 7,  2, 9,  4, 11]
    out_accumulated_raw.rewind
    out_accumulated_raw.each_with_index do |line, index|
      accumulated_set = line.split(' ').map &:to_i
      set = accumulated_set.values_at(*stepwise)
      out_stepwise_raw.print "#{set.join ' '}\n"
      out_stepwise.puts "#{index + 1} #{set}"
    end
    nil
  end

  def octave_size
    12
  end

  def open(s, bidirectional=false)
    mode = bidirectional ? 'w+' : 'w'
    is_raw = s.end_with? '-raw'
    suffix = is_raw ? '' : '.txt'
    basename = "#{s}-#{fifth_min.abs}-#{fifth_max.abs}#{suffix}"
    filename = "#{directory_output}/#{basename}"
    result = ::File.open filename, mode
    @@output_raw << [filename, result] if is_raw
    result
  end

  def out
    @@out ||= open 'output'
  end

  def out_accumulated
    @@out_accumulated ||= open 'output-fifth-accumulated'
  end

  def out_accumulated_raw
    @@out_accumulated_raw ||= open 'output-fifth-accumulated-raw', true
  end

  def out_fifth
    @@out_fifth ||= open 'output-fifth'
  end

  def out_fifth_raw
    @@out_fifth_raw ||= open 'output-fifth-raw', true
  end

  def out_stepwise
    @@out_stepwise ||= open 'output-fifth-stepwise'
  end

  def out_stepwise_raw
    @@out_stepwise_raw ||= open 'output-fifth-stepwise-raw', true
  end

  def out_third
    @@out_third ||= open 'output-third'
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
    out.puts "A range #{fifth_range} of fifths produces:"
    @@output_raw = []

    third_sets_build
    out.puts
    out.puts "* #{@@third_sets_length} sets of thirds, rising to"
    out.puts '      G D A E B F# C# G# D# A# F C'
    return if @@third_sets_length.zero?

    fifth_sets_build
    out.puts
    out.puts "* #{@@fifth_sets_length} sets of fifths, also rising to"
    out.puts '      G D A E B F# C# G# D# A# F C'
    return if @@fifth_sets_length.zero?

    fifth_accumulated_sets_build
    out.puts
    out.puts '* Corresponding accumulated fifths, rising to'
    out.puts '      G D A E B F# C# G# D# A# F C'

    fifth_stepwise_sets_build
    out.puts
    out.puts '* Corresponding reordered stepwise notes, indicating the positions of'
    out.puts '      C# D D# E F F# G G# A A# B C'

    tuning_sets_build
    out.puts
    out.puts '* And corresponding tuning sets, also indicating the positions of'
    out.puts '      C# D D# E F F# G G# A A# B C'

    output_raw_delete
    nil
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
    @@third_max ||= fifth_max * third_major_size
  end

  def third_min
    @@third_min ||= fifth_min * third_major_size
  end

  def third_set_save
    set = [
        @@third_1,  @@third_2,  @@third_3,  @@third_4,
        @@third_5,  @@third_6,  @@third_7,  @@third_8,
        @@third_9,  @@third_10, @@third_11, @@third_12,
        ]
    @@third_sets_length += 1
    out_third_raw.print "#{set.join ' '}\n"
    out_third.puts "#{@@third_sets_length} #{set}"
    nil
  end

  def third_sets_build
    @@third_sets_length = 0
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

  def tuning_sets_build
    out_fifth_raw.rewind
    out_stepwise_raw.rewind
    out_stepwise_raw.each_with_index do |line, index|
      stepwise_set = line.split(' ').map &:to_i
      circle_set = out_fifth_raw.readline.split(' ').map &:to_i
      third_smallest = circle_set.values_at(*third_smallest_enum).sum
      unit = (third_major_just_difference_cents / third_smallest).abs
# p unit
      set = stepwise_set.each_with_index.map do |note, i|
        offset = note * unit
        equal_tempered = 100.0 * i.succ
        equal_tempered + offset
      end
      out_tuning.puts "#{index + 1} #{set.map{|e| e.round 5}}"
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
