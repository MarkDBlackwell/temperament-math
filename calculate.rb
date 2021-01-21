def fifth_max
  1
end

def fifth_min
  -2
end

def good_find
  @good_find ||= begin
    universe_size.times.map do |e|
      fifths = octave_size.times.map do
        element = e % radix + fifth_min
        e = e.div radix
        element
      end
      next unless 0 == fifths.sum
      thirds = thirds_build fifths
      next unless thirds_match_octave? thirds
      next unless thirds.uniq.length == thirds.length
      fifths
    end.compact
  end
end

def octave_size
  12
end

def radix
  @radix ||= begin
    fifth_max - fifth_min + 1
  end
end

def run
  # p thirds_combined
  p "#{fifth_min} #{fifth_max}"
  p universe_size
  good = good_find
  good_length = good.length
  p good_length
  [good_length, 10].min.times do |i|
    fifths = good.at i
    p "#{fifths} #{thirds_build fifths}"
  end
end

def third_major_size
  4
end

def thirds_build(fifths)
  octave_size.times.map do |step|
    third_major_size.times.map do |offset|
      index = (step - offset) % octave_size
      fifths.at index
    end.sum
  end
end

def thirds_combined
  @thirds_combined ||= begin
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

def thirds_match_octave?(thirds)
  thirds_combined.each do |e|
    ring = e.map do |i|
      thirds.at i
    end
    return false unless 0 == ring.sum
  end
  true
end

def universe_size
  @universe_size ||= begin
    radix ** octave_size
  end
end

run
