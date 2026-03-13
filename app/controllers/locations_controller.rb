require "net/http"
require "json"

class LocationsController < ApplicationController
  def search
    query = params[:q]
    return render json: [] if query.blank?

    begin
      url = URI("https://nominatim.openstreetmap.org/search")

      url.query = URI.encode_www_form(
        q: query,
        format: "json",
        addressdetails: 1,
        limit: 5
      )

      request = Net::HTTP::Get.new(url)
      request["User-Agent"] = "Rails Location Autocomplete"

      response = Net::HTTP.start(url.hostname, url.port, use_ssl: true) do |http|
        http.request(request)
      end

      results = JSON.parse(response.body)

      cities = results.map do |place|
        city =
          place.dig("address", "city") ||
          place.dig("address", "town") ||
          place.dig("address", "village")

        country = place.dig("address", "country")

        next unless city && country

        { city: city, country: country }
      end.compact

      render json: cities

    rescue StandardError => e
      Rails.logger.error("Location search failed: #{e.message}")
      render json: []
    end
  end
end
