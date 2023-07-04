require "http/client"
require "json"
require "../models/travel_plan_expanded.cr"

class LocationResponse
  include JSON::Serializable

  @[JSON::Field(key: "id")]
  property id : Int32

  @[JSON::Field(key: "name")]
  property name : String

  @[JSON::Field(key: "type")]
  property type : String

  @[JSON::Field(key: "dimension")]
  property dimension : String

  @[JSON::Field(key: "residents")]
  property residents : Array(String)

  @[JSON::Field(key: "url")]
  property url : String

  @[JSON::Field(key: "created")]
  property created : String
end

class CharacterResponse
  include JSON::Serializable

  @[JSON::Field(key: "episode")]
  property episode : Array(String)
end

def get_rick_and_morty_api_results(id : Int64)
  response = HTTP::Client.get "https://rickandmortyapi.com/api/location/#{id}"

  location_response = LocationResponse.from_json(response.body)

  episodes = 0
  location_response.residents.each do |resident|
    resident_response = HTTP::Client.get resident
    character = CharacterResponse.from_json(resident_response.body)

    episodes += character.episode.size
  end

  Location.from_response(location_response, episodes)
end
