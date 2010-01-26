require 'uri'

URI::PATTERN.const_set('PARAMETER_UNSAFE', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]").freeze)

class << URI
  def escape_parameter(parameter)
    URI.encode parameter, URI::PATTERN::PARAMETER_UNSAFE
  end

  def conservative_escape_parameter(parameter)
    URI.encode parameter, /[&=%+ ]/
  end

  alias :encode_parameter :escape_parameter
  alias :conservative_encode_parameter :conservative_escape_parameter

end
