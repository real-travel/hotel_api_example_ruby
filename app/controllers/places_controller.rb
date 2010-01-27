require 'ruby-debug'
require 'xml'
require 'ostruct'

class PlacesController < ApplicationController
  AFFILIATE_ID = 'f8ejKn3983H'
  API_HOST = 'http://api.staging.realtravel.com' # http://localhost:3001

  def index
    @places = ZipCode.all(:limit => 100, :conditions => 'latitude IS NOT NULL')
  end

  def show
    @place = Place.find(params[:id])
    document = http_client("/hotels.xml",{:latitude => @place.latitude, :longitude => @place.longitude}.merge(catch_filters))
    page = document.find('//hotels').first.attributes['page']
    per_page = document.find('//hotels').first.attributes['per_page']
    total = document.find('//hotels').first.attributes['total']
    
    @hotels = WillPaginate::Collection.create(page, per_page, total) do |pager|
      hotel_list = []

      document.find('//hotel').each do |hotel|
        hotel_list << OpenStruct.new(
          :hotel_id => hotel.find('@id').first.value,
          :photo => hotel.find('photo').first.content,
          :name => hotel.find('name').first.content,
          :address => hotel.find('address').first.content,
          :rating => hotel.find('rating').first.content,
          :star_rating => hotel.find('starrating').first.content,
          :description => hotel.find('description').first.content,
          :amenities => hotel.find('amenities').first.content,
          :latitude => hotel.find('latitude').first.content,
          :longitude => hotel.find('longitude').first.content,
          :recommendation => hotel.find('recommendation').first.content,
          :recommendation_image => hotel.find('recommendation').first.attributes['image']
        )
      end
      pager.replace(hotel_list)
    end    

  end

  def show_hotel
    @place = Place.find(params[:id])
    document = http_client("/hotels/#{params[:hotel_id]}.xml",{:latitude => @place.latitude, :longitude => @place.longitude})
    hotel = document.find('//hotel').first

    @hotel = OpenStruct.new(
      :hotel_id => hotel.find('@id').first.value,
      :photo => hotel.find('photo').first.content,
      :name => hotel.find('name').first.content,
      :address => hotel.find('address').first.content,
      :rating => hotel.find('rating').first.content,
      :star_rating => hotel.find('starrating').first.content,
      :description => hotel.find('description').first.content
    )

  end

  def show_hotel_prices
    @place = Place.find(params[:id])
    document = http_client("/hotels/#{params[:hotel_id]}/availability.xml",params[:availability])

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

  def catch_filters
    @catch_filters ||= {}
    [:hotel_class, :lowest_price, :highest_price, :distance, :page, :per_page].each do |filter|
      @catch_filters[filter] = params[filter] if params[filter]
    end
    @catch_filters
  end
  
  def http_client(url,params={})
    params = params.merge(:affiliate_id => AFFILIATE_ID)
    SimpleService::HttpService.logger = logger
    client = SimpleService::HttpService.new(
      :url => API_HOST + url, 
      :timeout => 10, 
      :context => self
    )
    XML::Parser.string(client.get(params)).parse
  end
  
end
