require 'faster_csv'

module DataStore

  PLACES_FILE="#{RAILS_ROOT}/db/data/zip_codes_cities_counties.csv"
  
  class PlacesImporter

    attr_accessor :places_map, :state_abbreviations, :places_file
    
    def initialize(places_file=DataStore::PLACES_FILE)
      raise ArgumentError, "places file not found" unless File.exist? places_file
      @places_map, @state_abbreviations, @places_file = {}, {}, places_file
    end

    def import!
      build!
      persist!      
    end

    protected
    
    def build!
      FasterCSV.foreach(@places_file, :headers => true, :skip_blanks => true) do |record|
        # ZipCode,City,State,County,Latitude,Longitude
        begin
          state_abbreviation, county, city, zip_code, latitude, longitude = record["State"], %(#{record["County"] ? "#{record['County'].titleize} County" : 'Other'} ).strip, record["City"].titleize.strip, record["ZipCode"].strip, record["Latitude"], record["Longitude"]
          state = state_map[state_abbreviation]
          @places_map[state] ||= {}
          @places_map[state][county] ||= {}
          @places_map[state][county][city] ||= {}
          @places_map[state][county][city][zip_code] = [latitude, longitude]
          @state_abbreviations[state] = state_abbreviation
        rescue => e
          puts record.inspect
          raise e
        end
      end 

    end  

    def state_map
      @state_map ||= {
        "AL"=>"Alabama", "ND"=>"North Dakota", "VA"=>"Virginia", "NY"=>"New York", 
        "MD"=>"Maryland", "CO"=>"Colorado", "RI"=>"Rhode Island", "NE"=>"Nebraska", 
        "HI"=>"Hawaii", "DE"=>"Delaware", "MN"=>"Minnesota", "MO"=>"Missouri", 
        "WY"=>"Wyoming", "IA"=>"Iowa", "ME"=>"Maine", "OR"=>"Oregon", "KY"=>"Kentucky", 
        "OH"=>"Ohio", "AZ"=>"Arizona", "IL"=>"Illinois", "TN"=>"Tennessee", "TX"=>"Texas", 
        "GA"=>"Georgia", "NH"=>"New Hampshire", "IN"=>"Indiana", "ID"=>"Idaho", 
        "SC"=>"South Carolina", "PA"=>"Pennsylvania", "CT"=>"Connecticut", "FL"=>"Florida", 
        "NJ"=>"New Jersey", "SD"=>"South Dakota", "MS"=>"Mississippi", "AR"=>"Arkansas", 
        "MI"=>"Michigan", "OK"=>"Oklahoma", "MT"=>"Montana", "WI"=>"Wisconsin", "NV"=>"Nevada", 
        "VT"=>"Vermont", "CA"=>"California", "KS"=>"Kansas", "NM"=>"New Mexico", "UT"=>"Utah", 
        "WV"=>"West Virginia", "DC"=>"District of Columbia", "MA"=>"Massachusetts", 
        "WA"=>"Washington", "AK"=>"Alaska", "LA"=>"Louisiana", "NC"=>"North Carolina",
        "MH"=>"Marshall Islands", "MP"=>"Northern Mariana Islands", "FM"=>"Federated States of Micro", "PW"=>"Palau", "VI"=>"Saint Thomas", "AS"=>"American Samoa",
        "VI"=>"Saint Thomas","AR"=>"Army Post Office", "PR"=>"Adjuntas", "GU"=>"Guam", "AA"=>"Armed Forces Americas","AP"=>"Armed Forces Pacific" , "AE"=>"Armed Forces Europe"
      }
    end
    
    def persist!
      raise "places map is nill or blank" if @places_map.blank?
      puts Place.count # load the Place class file
      @places_map.each do |state_name, county_hash|
        state = State.create(:name => state_name, :abbreviation => @state_abbreviations[state_name])
        county_hash.each do |county_name, city_hash|
          county = County.create(:name => county_name)
          city_hash.each do |city_name, zip_code_hash|
            city = City.create(:name => city_name)
            zip_code_hash.each do |zip_code_name, (latitude,longitude)|
              city.children << ZipCode.create(:name => zip_code_name, :latitude => latitude, :longitude => longitude)              
              puts "#{zip_code_name} > #{state_name} > #{county_name} > #{city_name}" if RAILS_ENV != 'test'
            end
            county.children << city
          end
          state.children << county
        end
        state.save!        
      end
    end
    
  end
  
end