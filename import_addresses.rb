# import_addresses.rb
#!/usr/bin/ruby
require 'dotenv'
Dotenv.load('config.env')
require 'csv'
require 'httparty'
require 'json'
require_relative 'locations'

def get_token
  token_request = HTTParty.post("https://territoryhelper.com/api/token?client_id=#{ENV['TH_CLIENT_ID']}&client_secret=#{ENV['TH_CLIENT_SECRET']}&grant_type=refresh_token&refresh_token=#{ENV['TH_REFRESH_TOKEN']}")
  if token_request.code != 200
   p "Something is wrong, here is the error code: #{token_request.code}"
   exit
  end
  @access_token = token_request["access_token"]
  puts "Success token request!! access_token: #{@access_token}"
end

## Source file  ##
  csv_file_with_locations = "## redacted ##"
  puts " Reading data from  : #{csv_file_with_locations}"

  def create_territory_staging_table
    territories = HTTParty.get("https://territoryhelper.com/api/territories?access_token=#{@access_token}")
    territory_types = HTTParty.get("https://territoryhelper.com/api/territorytypes?access_token=#{@access_token}")
    ## changing key in territory type hashes so both territories and territory_types have same key to merge them
    territory_types = territory_types.parsed_response.each do |x|
      x["TerritoryTypeId"] = x.delete("Id")
       end
    territories = territories.parsed_response
    @staged_terr_info = territories.each do |x|
       territory_types.each do  |type|
       if type["TerritoryTypeId"] == x["TerritoryTypeId"]
        putting_them_together = x.merge!(type)
        ## above variable "putting_them_together" is more for the future reader to know what took place above ##
       end
     end
   end
  end

### Getting ready to starting importing ###

get_token
create_territory_staging_table
#puts @staged_terr_info

## Looks up IDs so these can be used when importing aka api call to territory helper api
  def lookup_territoryid(name, number)
    @staged_terr_info.each do |territory|
      if (territory["Name"].strip == name && territory["Number"].strip == number )
        @territoryID = territory["Id"]
      end
    end
  end


## Read from csv file , start loop thet continues to the end of this script, leveraging CSV library, side note, a Location class may not be really necessary here since CSV takes care of creating objects and can set respective attributes to send via API but decided to implement a class since it might come handy if this simple script were to be extended into a more complex system/app.
   table = CSV.foreach(csv_file_with_locations , :headers => true) do |row|
     #headers: Name,Number,House_number,Street,City
     puts row
## getting TerritoryID from staged territory data ###
    lookup_territoryid(row["Name"],row["Number"])
    puts @territoryID
    new_location = Location.new
    new_locationset_address_attributes(row["House_number"],row["Street"],row["City"])



    # SENDING TO TERRITORY HELPER ##
    url = "https://territoryhelper.com/api/territories/#{@territoryID}/locations?access_token=#{@access_token}"
    @result = HTTParty.post(url,
        :body => {
            :CongregationId => XXXXX, ## redacted ##
            :TerritoryId => @territoryID,
            :TypeId => new_location.TypeId,
            :Approved =>  true,
            :StatusId => 0,
            :LanguageId => nil,
            :Address => new_location.Address,
            :Number => new_location.Number,
            :StreetName => new_location.StreetName,
            :City => new_location.City,
            :County => new_location.County,
            :PostalCode => new_location.PostalCode,
            :State => "IN",
            :CountryCode => "US",
            :LatLng => new_location.LatLng,
            :Notes => nil,
            :DateLastVisited => nil
    }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    p @result
    p @result.code

    end
  ##### End of CSV.foreach loop, job done!  ##
