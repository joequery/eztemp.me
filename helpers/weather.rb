# Methods related to getting weather data

require 'open-uri'
require 'cgi'
require 'json'
require_relative 'secret' # includes forecast io api key

# This data can be found under the Data Points section of
# https://developer.forecast.io/docs/v2
def precip_intensity_to_str(precip_intensity)
    intensity = precip_intensity.to_f()
    intense_str = ""

    if intensity >= 0.4
        intense_str = "heavy"
    elsif intensity >= 0.1
        intense_str = "moderate"
    elsif intensity >= 0.017
        intense_str = "light"
    elsif intensity >= 0.002
        intense_str = "very light"
    else
        intense_str = "none"
    end
end

def get_weather_from_latlong(lat, long)
    base_url = "https://api.forecast.io/forecast"
    latlong_str = "#{lat},#{long}"
    full_url = "#{base_url}/#{$FORECAST_IO_KEY}/#{latlong_str}"

    results = ""
    open(full_url) do |f|
        results = f.read()
    end
    weather_data = JSON.load(results)

    converted_weather_data = {}
    converted_weather_data[:currently] = current_weather_from_weather_data(weather_data)
    converted_weather_data[:forecast] = forecast_from_weather_data(weather_data)

    return converted_weather_data
end

def current_weather_from_weather_data(weather_data)
    currently = weather_data['currently']
    current_data = data_from_weather_day(currently)
    current_data[:temp] = currently['temperature']
    return current_data
end

def forecast_from_weather_data(weather_data)
    daily = weather_data['daily']
    forecast = {}
    forecast[:summary] = daily['summary']
    forecast[:days] = []

    daily['data'].each do |day|
        this_days_weather =  data_from_weather_day(day)

        # Users don't care about temperature decimal places
        this_days_weather[:max_temp] = day['temperatureMax'].to_i()
        this_days_weather[:min_temp] = day['temperatureMin'].to_i()

        forecast[:days] << this_days_weather

    end
    return forecast
end

def data_from_weather_day(weather_day)
    key_mapping = {
        'time' => :timestamp,
        'summary' => :summary,
        'precipIntensity' => :precip_intensity,
        'precipProbability' => :precip_prob,
        'apparentTemperature' => :temp_feels_like
    }

    # Extract the data we want from the current_weather hash, and map the values
    # to the keys we want
    weather_data = {}
    key_mapping.each do |oldkey, newkey|
        weather_data[newkey] = weather_day[oldkey]
    end

    # Formatting

    # Convert numeric intensity to string
    intensity = weather_data[:precip_intensity]
    if !intensity.nil?
        weather_data[:precip_intensity] = precip_intensity_to_str(intensity)
    end

    # Convert precipitation probability to percentage
    precip_prob = weather_data[:precip_prob]
    if !precip_prob.nil?
        precip_prob = (precip_prob*100).to_i()
        weather_data[:precip_prob] = "#{precip_prob}%"
    end

    # Add a date str equivalent to a timestamp, if provided
    timestamp = weather_data[:timestamp]
    if !timestamp.nil?
        date_str = Time.at(timestamp).strftime("%a %b %-d, %Y")
        weather_data[:date_str] = date_str
    end
    return weather_data
end


