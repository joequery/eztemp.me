# Functionality related to gathering location from an ip adddress

require 'open-uri'
require 'cgi'
require 'json'
require_relative 'secret' # google api key

def get_geo_from_ip(ip_addr)
    base_url = "https://freegeoip.net/json/"
    full_url = base_url + ip_addr

    results = ""
    open(full_url) do |f|
        results = f.read()
    end

    geo_data = JSON.load(results)
    geo_data['location_str'] = "#{geo_data['city']}, #{geo_data['region_name']}"

    return geo_data
end

def get_geo_from_location_str(loc_str)
    base_url = "https://maps.googleapis.com/maps/api/geocode/json?sensor=false"
    key_portion = "&key=#{$GOOGLE_API_KEY}"

    encoded_locstr = CGI.escape(loc_str)
    full_url = base_url + key_portion + "&address=#{encoded_locstr}"

    results = ""
    open(full_url) do |f|
        results = f.read()
    end

    data = JSON.load(results)['results'][0]
    if data.nil?
        return nil
    end

    # We want our geo data to match the used portions of the freegoip format so
    # we can use them interchangeably
    geo_data = {
        'location_str' => data['formatted_address'],
        'latitude' => data['geometry']['location']['lat'],
        'longitude' => data['geometry']['location']['lng']
    }
    return geo_data
end
