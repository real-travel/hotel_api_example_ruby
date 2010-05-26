module RT
  module API

    def self.settings
      @@settings ||= begin
        YAML.load(IO.read(File.join(RAILS_ROOT, "config", "hotel_api.yml")))
      end
    end
    
  end
end