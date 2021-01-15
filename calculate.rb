def octave_size
  12
end

def third_major_size
  4
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

def fifth_max
  1
end

def fifth_min
  -2
end

def radix
  @radix ||= begin
    fifth_max - fifth_min + 1
  end
end

def universe_size
  @universe_size ||= begin
    radix ** octave_size
  end
end

def thirds_check(third)
  thirds_combined.each do |e|
    ring = e.map do |i|
      third.at i
    end
    return false unless 0 == ring.sum
  end
  true
end

def thirds_build(fifth)
  octave_size.times.map do |step|
    third_major_size.times.map do |offset|
      index = (step - offset) % octave_size
      fifth.at index
    end.sum
  end
end

def good_find
  @good_find ||= begin
    universe_size.times.map do |e|
      fifth = octave_size.times.map do
        element = e % radix + fifth_min
        e = e.div radix
        element
      end
      next unless 0 == fifth.sum
      third = thirds_build fifth
      next unless thirds_check third
      fifth
    end.compact
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
    fifth = good.at i
    p "#{fifth} #{thirds_build fifth}"
  end
end

run
