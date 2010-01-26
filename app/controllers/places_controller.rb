require 'ruby-debug'
require 'xml'
require 'ostruct'
class PlacesController < ApplicationController
  AFFILIATE_ID='f8ejKn3983H'

  def index
    @places = ZipCode.all(:limit => 100, :conditions => 'latitude IS NOT NULL')
  end

  def show
    @place = Place.find(params[:id])
    document = http_client("http://localhost:3001/hotels.xml",{:latitude => @place.latitude, :longitude => @place.longitude})
    hotels = document.find('//hotel')

    @hotels = []
    hotels.each do |hotel|
      @hotels << OpenStruct.new(
        :hotel_id => hotel.find('@id').first.value,
        :photo => hotel.find('photo').first.content,
        :name => hotel.find('name').first.content,
        :address => hotel.find('address').first.content,
        :rating => hotel.find('rating').first.content,
        :star_rating => hotel.find('starrating').first.content,
        :description => hotel.find('description').first.content,
        :destination => hotel.find('destination').first.content
      )
    end

  end

  def show_hotel
    @place = Place.find(params[:id])
    document = http_client("http://localhost:3001/hotels/#{params[:hotel_id]}.xml",{:latitude => @place.latitude, :longitude => @place.longitude})
    hotel = document.find('//hotel').first

    @hotel = OpenStruct.new(
      :hotel_id => hotel.find('@id').first.value,
      :photo => hotel.find('photo').first.content,
      :name => hotel.find('name').first.content,
      :address => hotel.find('address').first.content,
      :rating => hotel.find('rating').first.content,
      :star_rating => hotel.find('starrating').first.content,
      :description => hotel.find('description').first.content,
      :destination => hotel.find('destination').first.content
    )

  end

  def show_hotel_prices
    @place = Place.find(params[:id])
    document = http_client("http://localhost:3001/hotels/#{params[:hotel_id]}/availability.xml",params[:availability])

    @hotel = OpenStruct.new(
      :hotel_id => document.find('//hotel/@id').first.value,
      :name => document.find('//hotel/name').first.content
    )

    @pricing = []
    document.find('//hotel/availability/source').each do |source|
      @pricing << OpenStruct.new(
        :name => source.find('@name').first.value,
        :price => source.find('@price').first ? source.find('@price').first.value : 'Check Site',
        :url => source.first.content
      )
    end

  end
  
  private
  
  def http_client(url,params={})
    params = params.merge(:affiliate_id => AFFILIATE_ID)
    SimpleService::HttpService.logger = logger
    client = SimpleService::HttpService.new(
      :url => url, 
      :timeout => 10, 
      :context => self
    )
    XML::Parser.string(client.get(params)).parse
  end
  
end
