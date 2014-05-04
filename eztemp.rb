require 'sinatra'
require_relative 'helpers/geolocation'
require_relative 'helpers/weather'

if ENV['PRODUCTION'].nil?
    puts '=' * 50
    puts "Running development server..."
    puts '=' * 50

    # Necessary when running within vagrant
    set :bind, '0.0.0.0'
end

get '/' do
    @geodata = get_geo_from_ip(request.ip)
    @weather = get_weather_from_latlong(@geodata['latitude'], @geodata['longitude'])
    erb :index
end
