require 'rubygems'
require 'httparty'
require 'hashie'

 #BreweryDb.configure do |config|
 #  config.apikey = 'API_KEY'
 #end
 
class BreweryDb
  include HTTParty
  # debug_output $stdout
  base_uri 'http://api.brewerydb.com/v2/'
  format :json
  default_params :format => 'JSON'

  class << self
    
    attr_accessor :apikey
    
    # plural endpoints
    ["beers", "breweries", "categories", "events", "features", "fluidsizes", "guilds", "ingredients", "locations", "socialsites", "styles"].each do |endpoint|
      define_method endpoint do |*options|
        self.send_request("/#{endpoint}", options.first || {})
      end
      
      # singular endpoints
      define_method endpoint.singularize do |id, *options|
        self.send_request("/#{endpoint.singularize}/#{id}", options.first || {})
      end  
    end
    
    # menu endpoints
    # BreweryDb.menu_type (example BreweryDb.menu_styles)
    # Hyphens in endpoints become underscores in method definition    
    ["styles","categories","glassware","srm","beer-availability","fluidsize","beer-temperature","countries","ingredients","location-types","fluidsize-volume","event-types"].each do |type|
      define_method "menu_#{type.gsub("-", "_")}" do |*options|
        self.send_request("/menu/#{type}", options.first || {})
      end
    end
    
    # search endpoints
    # BreweryDb.search_type (example BreweryDb.search_geo_point)
    # Hyphens in endpoints become underscores in method definition 
    ["geo_point","upc"].each do |type|
      define_method "search_#{type}" do |*options|
        self.send_request("/search/#{type.gsub("_","/")}", options.first || {})
      end
    end
    
    # misc additional endpoints
    def glass(id,options={});   send_request("/glassware/#{id}", options);  end
    def glassware(options={});  send_request("/glassware", options);        end
    def search(options={});     send_request("/search", options);           end
    def convertid(options={});  send_request("/convertid", options);        end
    def search;                 send_request('/search', options);           end
    def heartbeat;              send_request("/heartbeat");                 end
    def featured;               send_request("/featured");                  end
    
    
    def send_request(endpoint, options={})
      raise Exception.new('BreweryDb API Key not set') if !apikey
      options.merge!({
        :key => apikey
      })
      response = get(endpoint, :query => options)
      Hashie::Mash.new(response)
    end
  end

  def self.configure; yield self; end  
end