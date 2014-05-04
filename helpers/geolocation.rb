# Functionality related to gathering location from an ip adddress

require 'open-uri'
require 'cgi'
require 'json'

def get_geo_from_ip(ip_addr)
    base_url = "https://freegeoip.net/json/"
    full_url = base_url + ip_addr

    results = ""
    open(full_url) do |f|
        results = f.read()
    end

    geo_data = JSON.load(results)
    return geo_data
end
