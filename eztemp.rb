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
    @loc_str = params[:location]
    if @loc_str.nil?
        @geodata = get_geo_from_ip(request.ip)
    else
        @geodata = get_geo_from_location_str(@loc_str)
    end

    if @geodata.nil?
        return erb :notfound
    end

    @weather = get_weather_from_latlong(@geodata['latitude'], @geodata['longitude'])
    erb :index
end
