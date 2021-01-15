octave_size = 12
third_major_size = 4
ring = (octave_size.div third_major_size).times.map do |e|
  third_major_size * e
end
thirds_combined = third_major_size.times.map do |offset|
  ring.map do |e|
    offset + e
  end
end
# p ring, thirds_combined

max = 1
min = -2
p min, max

radix = max - min + 1
universe_size = radix ** octave_size
# universe_size = 2
p universe_size

def thirds_check(fifth, thirds_combined)
  thirds_combined.each do |e|
    ring = e.map do |i|
      fifth.at i
    end
    return false unless 0 == ring.sum
  end
  true
end

good = universe_size.times.map do |e|
  fifth = octave_size.times.map do
    element = e % radix + min
    e = e.div radix
    element
  end
  next unless 0 == fifth.sum
  next unless thirds_check fifth, thirds_combined
  fifth
end.compact
p good.length
p good.first
