require 'rubygems'
require 'httparty'
require 'hashie'

#
# BreweryDb.configure do |config|
#   config.apikey = 'c0189f0299dd9333669a845b5ec14'
# end
#
class BreweryDb
  include HTTParty
  base_uri 'http://www.brewerydb.com/api'
  format :json
  default_params :format => 'JSON'
  @@apikey = nil

  (class << self; self; end).instance_eval do
    ["breweries", "beers", "styles", "categories"].each do |endpoint|
      define_method endpoint do |*options|
        options = options.first || { }
        options.merge!({
                         :key => apikey
                       })

        response = get("/#{endpoint}", :query => options)
        if response.code == 200
          Hashie::Mash.new(response['#{endpoint}'])
        else
          pp response
        end
      end
      define_method endpoint.singularize do |id, *options|
        options = options.first || { }
        options.merge!({
                         :key => apikey
                       })
        response = get("/#{endpoint}/#{id}", :query => options)
        if response.code == 200
          Hashie::Mash.new(response["#{endpoint}"]["#{endpoint.singularize}"])
        else
          pp request
          pp response
        end
      end
    end
  end

  def self.search(options={})
    options.merge!({
      :apikey => apikey
    })

    response = get("/search", :query => options)
    Hashie::Mash.new(response['results']) if response.code == 200
  end

  def self.glassware(options={})
    options.merge!({
      :apikey => apikey
    })

    response = get("/glassware", :query => options)
    Hashie::Mash.new(response['glassware']) if response.code == 200
  end

  def self.glass(id, options={})
    options.merge!({
      :apikey => apikey
    })

    response = get("/glassware/#{id}", :query => options)
    Hashie::Mash.new(response['glassware']['glass']) if response.code == 200
  end

  def self.apikey
    @@apikey
  end

  def self.apikey=(apikey)
    @@apikey = apikey
  end

  def self.configure
    yield self
  end

end

