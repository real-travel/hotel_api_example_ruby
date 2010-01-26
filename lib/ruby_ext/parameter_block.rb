# TODO jwl consolidate *_ext rails plugins and move this into the result

class Proc
  # convert invocations of '_' into an zipped array of parameters and values, preserving the order of definition
  def to_param_ary(*args)
    context = ParamArrayContext.new
    (class <<  context; self; end).send :define_method, :collect_parameters, self
    context.collect_parameters(*args)
    context.parameters
  end

  private
  
  class ParamArrayContext
    attr_reader :parameters
    
    protected

    def initialize
      @parameters = []
    end
    
    def add(name, value)
      @parameters << name
      @parameters << value if value
    end
    
    alias :_ :add
    
  end
end