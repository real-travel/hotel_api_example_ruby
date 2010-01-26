# ruby_core_ext.eb.rb
# November 8, 2007
#

module RubyCoreExt
  
  Set.class_eval do
    # Returns a string created by converting each element of the set to a string, separated by the given seperator.
    def join(seperator)
      @hash.keys.join seperator
    end
  end

end

class Array
  # Create a hash using this array as the keys and a given array as the values.
  # TODO jwl Consider a C/Java extension, as this is a little inefficient.
  def zip_hash(values)
    Hash[*self.zip(values).flatten]
  end
end

class Hash
  # Remove the entries with the given keys, returning them as a new hash.
  def extract(*keys)
    keys.inject({}) do |extracted, key|
      extracted[key] = delete key
      extracted
    end
  end
  
  # Get the value, if any, of the element found by applying the given keys to this recursive Hash.
  def path(*keys)
    keys.inject(self) do |found, key|
      break unless found
      found[key]
    end
  end
  
  # Convert all keys to symbols, including the keys of values that are also Hashes.
  # Keys that can't be converted to symbols are left unchanged, as with Rails' Hash#symbolize_keys.
  # Hashes inside Arrays will not have their keys converted.
  # NOTE: If the hash has a recursive structure, an exception will be raised.
  # TODO jwl correctly handle loops in the hash hierarchy.
  # TODO jwl convert the keys of Hashes inside Arrays by defining Array#symbolize_keys_recursively.
  # TODO jwl use a stack instead of a recursive call.
  def symbolize_keys_recursively(symbolizing = Set.new)
    symbolizing.add self
    symbolized = inject({}) do |options, (key, value)|
      if value.is_a? Hash
        raise "Hash cannot have a recursive structure." if symbolizing.include? value
        value = value.symbolize_keys_recursively symbolizing
      end
      
      options[(key.to_sym rescue key) || key] = value
      options
    end
    symbolizing.delete self
    symbolized
  end
  
  # Destructively convert all keys to symbols, including the keys of values that are also Hashes.
  # Keys that can't be converted to symbols are left unchanged, as with Rails' Hash#symbolize_keys.
  # Hashes inside Arrays will not have their keys converted.
  # NOTE: If the same Hash is a value at more than one point in the hierarchy, only one arbitrary instance will have it's keys
  # replaced.
  def symbolize_keys_recursively!
    self.replace(self.symbolize_keys_recursively)
  end

end

class Integer
  # convert an unsigned integer into a signed one of the given number of bytes
  # TODO jwl consider either raising and exception or truncating positive numbers, if bits above the given number of bytes are set
  def to_signed(bytes = self.size)
    sign_bit = bytes * 8 - 1
    self & (1 << sign_bit) != 0 ? self | (-2 << sign_bit) : self
  end
end
