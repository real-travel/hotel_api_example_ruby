module MongrelExt
  Mongrel::Configurator.class_eval do
    # prepend standard details to log entries
    def log_with_details(message)
      log_without_details "#{Time.now.xmlschema(4)} (#{$$}) #{message}"
    end
    alias_method_chain :log, :details
  end
end