require "json"

class TravelPlan
  include JSON::Serializable

  @[JSON::Field(key: "id")]
  property travel_plan_id : Int64

  @[JSON::Field(key: "travel_stops")]
  property travel_stops : Array(Int32)

  def initialize(travel_plan_id, travel_stops)
    @travel_plan_id =  travel_plan_id
    @travel_stops = travel_stops
  end
end
