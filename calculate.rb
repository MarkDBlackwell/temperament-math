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

TemperamentMath::run_old
