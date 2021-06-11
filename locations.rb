#locations.rb
#!/usr/bin/ruby
require 'dotenv'
Dotenv.load('config.env')
require 'httparty'
require 'json'

class Location

  attr_accessor :TerritoryId,
                :LocationUnits,
                :Id,
                :CongregationId,
                :TerritoryId,
                :TypeId,
                :Number,
                :StreetName,
                :County,
                :City,
                :PostalCode,
                :State,
                :CountryCode,
                :Address,
                :LatLng,
                :Notes,
                :Approved,
                :LanguageId,
                :StatusId,
                :DateVisited


      def LocationUnits
        @LocationUnits || []
      end

      def CongregationId
        @CongregationId || XXXXXX  ## redacted ##
      end

      def TypeId
        @TypeId || 0
      end

      def Approved
        @Approved || true
      end

      def StatusId
        @StatusId || 0
      end
      def State
        @State || "XXXXXX" ## redacted ##
      end
      def CountryCode
        @CountryCode || "XXXXXX" ## redacted ##
      end

### Gets + sets Location attributes: postal code, street name, latitude, longitude, house number, full address, county ###
      def set_address_attributes(street_number,street_name,city)

       address =  [street_number,street_name,city].flat_map(&:itself).join("+").gsub(' ','+')
       google_geo_api = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{ENV['GOOGLE_API']}")
       ## start of loop through Google Geo API response, getting and setting Location attributes
       google_geo_api.parsed_response["results"].each do |api_response|
       #sets latitude, longitude, full address, zip code
           lat = api_response["geometry"]["location"]["lat"]
           lng = api_response["geometry"]["location"]["lng"]
           self.LatLng = "{\"lat\":#{lat},\"lng\":#{lng}}"
           self.Address = api_response["formatted_address"]
           self.StreetName = api_response["address_components"][1]["long_name"]
           #sets postal code
           api_response["address_components"].each do |x|
              if x["types"].include? "postal_code"
                self.PostalCode = x["long_name"]
              end
              ### Sets county
              if x["types"].include? "administrative_area_level_2"
                self.County = x["long_name"]
              end
            end
        end
        #sets house number
        self.Number = google_geo_api["results"][0]["address_components"].select{|x| x["types"] == ["street_number"]}.map{|x| x["long_name"]}.join
       end



end
