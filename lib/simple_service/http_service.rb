require 'ruby_ext/parameter_block'

module SimpleService

  class HttpService
    cattr_accessor :logger
  
    DEFAULT_TIMEOUT_SECONDS = 10
  
    def initialize(options = {})
      @url = URI::parse(options[:url])
      @timeout = options[:timeout] or DEFAULT_TIMEOUT_SECONDS
      @context = options[:context]
    end

    def post(*parameters, &parameter_block)
      url = @url.dup
      post_parameters = 
        if parameter_block
          parameter_block.to_param_ary(*parameters)
        else
          parameters.first
        end
      self.class.logger.debug "Url for #{@context}: #{url}"
    
      # TODO jwl test HTTP exception handling
      # TODO jwl insure this handles all cases of redirection properly -- it doesn't seem to do so currently
      body = request(url, post_parameters) do
        Net::HTTP.post_form(url,post_parameters).body
      end
    end
  
    # TODO jwl extract rails Hash#to_query dependency
    def get(*parameters, &parameter_block)
      url = @url.dup
      url.query = 
        if parameter_block
          parameters = parameter_block.to_param_ary(*parameters)
          parameters.param_ary_to_query if parameters
        else
          parameters = parameters.first
          parameters.to_query if parameters
        end
      self.class.logger.debug "Url for #{@context}: #{url}"

      body = request(url, {}) do
        Net::HTTP.get url
      end
    
    end
  
    # TODO jwl filter parameters, condense parameters, or eliminate this method
    def self.inspect_parameters(parameters = {})
      parameters.inspect
    end

    private
    
    def request(url, parameters)
      # TODO jwl test HTTP exception handling
      # TODO jwl insure this handles all cases of redirection properly -- it doesn't seem to do so currently
      begin
        Timeout::timeout(@timeout) do
          time_before = Time.now
          body = yield(url, parameters)
          self.class.logger.debug sprintf("#{@context} get/post completed in %.3f seconds.", Time.now.to_f - time_before.to_f)
          return body
        end
      rescue Net::HTTPExceptions => response
        self.class.logger.warn(
          "#{@context} get/post #{self.class.inspect_parameters parameters} returned http response code #{response.value}."
        )
      rescue SocketError => socket_error
        self.class.logger.warn(
          "#{@context} get/post #{self.class.inspect_parameters parameters} encountered a socket error: #{socket_error}."
        )
      rescue Timeout::Error
        self.class.logger.warn(
          "#{@context} get/post #{self.class.inspect_parameters parameters} timed out after #{@timeout} seconds."
        )
      end
    end

  end
end