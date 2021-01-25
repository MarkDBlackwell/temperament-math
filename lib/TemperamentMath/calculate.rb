# coding: utf-8

=begin
Copyright (C) 2021 Mark D. Blackwell.
   All rights reserved.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Author: Mark D. Blackwell
Dates:
2021-Jan-14: created (mdb)
=end

module TemperamentMath
  extend self

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
# Integers are immutable:
    @@fifth_sets << set
    nil
  end

  def fifth_sets_build
    @@fifth_sets = []
    @@third_sets.each do |third_set|
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

  def octave_size
    12
  end

  def run
    third_sets_build
    p @@third_sets.length
#   @@third_sets.sort.each{|e| p e}
    @@third_sets.each{|e| p e}

    fifth_sets_build
    p @@fifth_sets.length
#   @@fifth_sets.sort.each{|e| p e}
    @@fifth_sets.each{|e| p e}
    nil
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
# Integers are immutable:
    @@third_sets << set
    nil
  end

  def third_sets_build
    @@third_sets = []
    third_sets_build_level_1
    nil
  end

  def third_sets_build_level_1
# Walk disjointedly from both ends.
    catch :level_1 do
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_4,  third_edge_4  = third_min, third_min
          @@third_10, third_edge_10 = third_max, third_max
          unless valid_1?
            throw :level_1
          end
        when :small
          @@third_4 += 1
          unless valid_1?
            state = :large
            @@third_4 = third_edge_4
            third_edge_10 -= 1
            @@third_10 = third_edge_10
            unless valid_1?
              throw :level_1
            end
          end
        when :large
          @@third_10 -= 1
          unless valid_1?
            state = :small
            @@third_10 = third_edge_10
            third_edge_4 += 1
            @@third_4 = third_edge_4
            unless valid_1?
              throw :level_1
            end
          end
        end
        third_sets_build_level_2
      end
    end
    nil
  end

  def third_sets_build_level_2
    catch :level_2 do
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_5,  third_edge_5  = @@third_4  + 1, @@third_4  + 1
          @@third_11, third_edge_11 = @@third_10 - 1, @@third_10 - 1
          unless valid_2?
            throw :level_2
          end
        when :small
          @@third_5 += 1
          unless valid_2?
            state = :large
            @@third_5 = third_edge_5
            third_edge_11 -= 1
            @@third_11 = third_edge_11
            unless valid_2?
              throw :level_2
            end
          end
        when :large
          @@third_11 -= 1
          unless valid_2?
            state = :small
            @@third_11 = third_edge_11
            third_edge_5 += 1
            @@third_5 = third_edge_5
            unless valid_2?
              throw :level_2
            end
          end
        end
        third_sets_build_level_3
      end
    end
    nil
  end

  def third_sets_build_level_3
    catch :level_3 do
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_3, third_edge_3 = @@third_5  + 1, @@third_5  + 1
          @@third_9, third_edge_9 = @@third_11 - 1, @@third_11 - 1
          unless valid_3?
            throw :level_3
          end
        when :small
          @@third_3 += 1
          unless valid_3?
            state = :large
            @@third_3 = third_edge_3
            third_edge_9 -= 1
            @@third_9 = third_edge_9
            unless valid_3?
              throw :level_3
            end
          end
        when :large
          @@third_9 -= 1
          unless valid_3?
            state = :small
            @@third_9 = third_edge_9
            third_edge_3 += 1
            @@third_3 = third_edge_3
            unless valid_3?
              throw :level_3
            end
          end
        end
        third_sets_build_level_4
      end
    end
    nil
  end

  def third_sets_build_level_4
    catch :level_4 do
      state = :initial
      while true
        case state
        when :initial
          state = :small
          @@third_6,  third_edge_6  = @@third_3 + 1, @@third_3 + 1
          @@third_12, third_edge_12 = @@third_9 - 1, @@third_9 - 1
          unless valid_4?
            throw :level_4
          end
        when :small
          @@third_6 += 1
          unless valid_4?
            state = :large
            @@third_6 = third_edge_6
            third_edge_12 -= 1
            @@third_12 = third_edge_12
            unless valid_4?
              throw :level_4
            end
          end
        when :large
          @@third_12 -= 1
          unless valid_4?
            state = :small
            @@third_12 = third_edge_12
            third_edge_6 += 1
            @@third_6 = third_edge_6
            unless valid_4?
              throw :level_4
            end
          end
        end
        third_sets_build_level_5_6
      end
    end
    nil
  end

  def third_sets_build_level_5_6
    catch :level_5_6 do
      @@third_1 = - @@third_5 - @@third_9
      @@third_2 = - @@third_6 - @@third_10
      @@third_7 = - @@third_3 - @@third_11
      @@third_8 = - @@third_4 - @@third_12
      unless valid_5_6?
        throw :level_5_6
      end
      third_set_save
    end
    nil
  end

  def valid_1?
    @@third_10 >= @@third_4 + octave_size - 1
  end

  def valid_2?
    true &&
        @@third_11 >= [@@third_10 - fifth_span, @@third_5 + octave_size - 3].max  &&
        @@third_5  <=  @@third_4  + fifth_span
  end

  def valid_3?
    true &&
        @@third_9  >= [@@third_10 - fifth_span, (  3 - @@third_5 ) / 2, @@third_3 + octave_size - 5].max  &&
        @@third_3  <= [@@third_4  + fifth_span, (- 3 - @@third_11) / 2].min
  end

  def valid_4?
    true &&
        @@third_12 >= [@@third_11 - fifth_span, (  1 - @@third_4 ) / 2, @@third_6 + octave_size - 7].max  &&
        @@third_6  <= [@@third_5  + fifth_span, (- 1 - @@third_10) / 2].min
  end

  def valid_5_6?
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

#-------------
=begin
  def good_find_old
    @@good_find_old ||= begin
      universe_size_old.times.map do |e|
        fifths = octave_size.times.map do
          old_e = e
          e = e.div radix_old
          old_e % radix_old + fifth_min
        end
        next unless 0 == fifths.sum
        thirds = thirds_build_old fifths
        next unless thirds_match_octave_old? thirds
        next unless thirds.uniq.length == thirds.length
        fifths
      end.compact
    end
  end

  def radix_old
    @@radix_old ||= fifth_span + 1
  end

  def run_old
    # p thirds_combined_old
    p "#{fifth_min} #{fifth_max}"
    p universe_size_old
    good = good_find_old
    p good.length
    [good.length, 10].min.times do |i|
      fifths = good.at i
      p "#{fifths} #{thirds_build_old fifths}"
    end
    nil
  end

  def thirds_build_old(fifths)
    octave_size.times.map do |step|
      third_major_size.times.map do |offset|
        index = (step - offset) % octave_size
        fifths.at index
      end.sum
    end
  end

  def thirds_combined_old
    @@thirds_combined_old ||= begin
      ring = (octave_size.div third_major_size).times.map do |e|
        third_major_size * e
      end
      third_major_size.times.map do |offset|
        ring.map do |e|
          offset + e
        end
      end
    end
  end

  def thirds_match_octave_old?(thirds)
    thirds_combined_old.each do |e|
      ring = e.map do |i|
        thirds.at i
      end
      return false unless 0 == ring.sum
    end
    true
  end

  def universe_size_old
    @@universe_size_old ||= radix_old ** octave_size
  end
=end

TemperamentMath::run
