=begin
On throw and catch, see:
http://phrogz.net/ProgrammingRuby/tut_exceptions.html
http://coderwall.com/p/lhkkug/don-t-confuse-ruby-s-throw-statement-with-raise
http://stackoverflow.com/questions/3716801/what-is-catch-and-throw-used-for-in-ruby
=end

def m
  throw :quit
end
catch :quit do
  m
  p 'uncaught'
end

catch :stop_loop do
  2.times do |i|
    2.times do |e|
      a = [i, e]
      throw :stop_loop if [1, 0] == a
      p a
    end
  end
end
