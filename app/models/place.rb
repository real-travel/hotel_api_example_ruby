class Place < ActiveRecord::Base
  acts_as_tree :order => 'name'
  acts_as_mappable(
      :lat_column_name => 'latitude',
      :lng_column_name => 'longitude'
  )
  def self.search(options={})
    # fetch = state, county, and city
    # state = 'California'; county = 'Santa Clara County'
    # city = 'Mountain View' (city should never be passed in)
    options.delete_if { |k,v| v.blank? }

    places = begin
      if options['state'] and options['county']
        # city
        states = options['state'].split(',').compact.collect { |state| "'#{state}'" }.compact
        counties = options['county'].split(',').compact.collect { |county| "'#{county}'" }.compact
        county_clause = (!counties.include?("'all'")) ? "AND county IN (#{counties.join(',')})" : ''
        Note.connection.select_all(<<-SQL)
          SELECT 
            DISTINCT(city) AS city
          FROM 
            notes 
          WHERE
            state IN (#{states.join(',')})
            #{county_clause}
          ORDER BY city
        SQL
      elsif options['state']
        # county
        states = options['state'].split(',').compact.collect { |state| "'#{state}'" }
        Note.connection.select_all("SELECT DISTINCT(county) AS county FROM notes WHERE state IN (#{states.join(',')}) ORDER BY county")
      else
        # state
        Note.connection.select_all("SELECT DISTINCT(state) AS state FROM notes ORDER BY state")        
      end           
    end
    new_places = places.inject({}) do |hash, place| 
      hash[place.keys.first] ||= []
      hash[place.keys.first] << place.values.first
      hash
    end
    new_places
  end

  def self.auto_complete(prefix='', limit=25)
    city_string = prefix.to_s.downcase
    state_string = ''

    if city_string.include? ',' # plit up into cities
      places_array = city_string.split(',').map(&:strip)
      city_string = places_array[0]
      state_string = 
        "AND (LOWER(state.name) LIKE '#{places_array[1]}%' 
          OR LOWER(state.abbreviation) = '#{places_array[1]}')"
    end

    find_by_sql(<<-SQL)
      SELECT 
        city.id, 
        city.name, 
        state.name AS state_name, 
        state.abbreviation AS state_abbreviation, 
        county.name AS county_name 
      FROM 
        places AS city 
      JOIN places AS county ON county.id = city.parent_id 
      JOIN places AS state ON county.parent_id = state.id 
      AND LOWER(city.name) LIKE '#{city_string}%' #{state_string}  
      ORDER BY city.name, state.name LIMIT #{limit.to_s}
    SQL
  end

end
