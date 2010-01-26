class Array
  public
  # yields the members of an array in a random order,
  # with original indices.
  #
  # Example:
  #  words = %w(dog cat rat rooster crow)
  #  words.pop_all_randomly { |word, index| puts "#{word} (originally word #{index})" }
  # ...yields...
  #  rat (originally word 2)
  #  rooster (originally word 3)
  #  crow (originally word 4)
  #  cat (originally word 1)
  #  dog (originally word 0)
  def pop_all_randomly
    temp = Array.new(self)
    length.times do |i|
      val = temp[rand(temp.length)]
      temp.delete(val)
      old_index = index(val)
      yield [val, old_index]
    end
  end
end
