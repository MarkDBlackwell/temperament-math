=begin
Author: Mark D. Blackwell
Dates:
2021-Jan-14: created (mdb)
=end

module TemperamentMath
  extend self

  def fifth_max
    1
  end

  def fifth_min
    -1
  end

  def fifth_span
    @@fifth_span ||= fifth_max - fifth_min
  end

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

  def octave_size
    12
  end

  def radix_old
    @@radix_old ||= fifth_span + 1
  end

  def run
    third_sets = third_sets_build
    p third_sets.length
    p third_sets
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

  def third_sets_build
# Walk disjointedly from both ends.
    result = []
    @@third_4 = third_min
    @@third_10 = third_max

    done_level_1 = false
    until done_level_1
#     p 'in level 1'
      catch :level_1 do
        throw :level_1
      end
#     p 'caught 1 okay'
      done_level_1 = true

      done_level_2 = false
      until done_level_2
#       p 'in level 2'
        catch :level_2 do
          throw :level_2
        end
#       p 'caught 2 okay'
        done_level_2 = true

        done_level_3 = false
        until done_level_3
#         p 'in level 3'
          catch :level_3 do
            throw :level_3
          end
#         p 'caught 3 okay'
          done_level_3 = true

          done_level_4 = false
          until done_level_4
#           p 'in level 4'
            catch :level_4 do
              throw :level_4
            end
#           p 'caught 4 okay'

            @@third_5 = @@third_4 + 1
            @@third_3 = @@third_5 + 1
            @@third_6 = @@third_3 + 1
            @@third_2 = @@third_6 + 1
            @@third_7 = @@third_2 + 1

            @@third_11 = @@third_10 - 1
            @@third_9 = @@third_11 - 1
            @@third_12 = @@third_9 - 1
            @@third_8 = @@third_12 - 1
            @@third_1 = @@third_8 - 1

            set = [
                @@third_4,
                @@third_5,
                @@third_3,
                @@third_6,
                @@third_2,
                @@third_7,
                @@third_1,
                @@third_8,
                @@third_12,
                @@third_9,
                @@third_11,
                @@third_10,
                ]
# Integers are immutable.
            result << set.map{|e| e.succ}
            result << set

            done_level_4 = true
          end
        end
      end
    end
    result
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
end

TemperamentMath::run
