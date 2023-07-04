class Location
  property id : Int32
  property name : String
  property type : String
  property dimension : String
  property episodes : Int32

  def initialize(id : Int32, name : String, type : String, dimension : String, episodes : Int32)
    @id = id
    @name = name
    @type = type
    @dimension = dimension
    @episodes = episodes
  end

  def Location.from_response(response : LocationResponse, episodes : Int32)
    new_location = Location.new(response.id, response.name, response.type, response.dimension, episodes)

    new_location
  end
end
