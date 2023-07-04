require "../services/http_client.cr"

class TravelStopExpanded
  include JSON::Serializable
  
  @[JSON::Field(key: "id")]
  property id : Int32

  @[JSON::Field(key: "name")]
  property name : String

  @[JSON::Field(key: "type")]
  property type : String

  @[JSON::Field(key: "dimension")]
  property dimension : String

  def initialize(location : Location)
    @id = location.id
    @name = location.name
    @type = location.type
    @dimension = location.dimension
  end
end

class TravelPlanExpanded
  include JSON::Serializable

  @[JSON::Field(key: "id")]
  property travel_plan_id : Int64

  @[JSON::Field(key: "travel_stops")]
  property travel_stops : Array(TravelStopExpanded)

  def initialize(travel_plan_id, travel_stops)
    @travel_plan_id =  travel_plan_id
    @travel_stops = travel_stops
  end
end
 

