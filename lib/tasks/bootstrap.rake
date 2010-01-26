namespace :app do
  desc "imports city, state and county data into places"
  task :import_places => :environment do
    require 'data_store/places_importer'
    include DataStore
    PlacesImporter.new.import!
  end
  
end