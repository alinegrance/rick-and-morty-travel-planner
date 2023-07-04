require "json"
require "mysql"
require "./http_client.cr"
require "../data/travel_plan_repository"
require "../models/location.cr"
require "../models/not_found_exception.cr"
require "../models/travel_plan_expanded.cr"

class Dimension
  property locations : Array(Location)
  property episodes : Int32
  property name : String

  def initialize(name : String)
    @name = name
    @locations = [] of Location
    @episodes = 0
  end

  def average_population
    episodes / locations.size
  end
end

class TravelPlanOptimizer
  def initialize
  end

  def sort_locations(locations : Array(Location))
    locations.sort! do |a, b|
      (a.episodes <=> b.episodes) == 0 ? a.name.compare(b.name, case_insensitive=true) : a.episodes <=> b.episodes
    end
  end

  def sort_dimensions(dimensions : Array(Dimension))
    dimensions.each do |dimension|
    end

    dimensions.sort! do |a, b|
      (a.average_population <=> b.average_population) == 0 ? a.name.compare(b.name, case_insensitive=true) : a.average_population <=> b.average_population
    end
  end

  def do_optimize(locations : Array(Location))
    dimensions = Hash(String, Dimension).new
    locations.each do |location|
      if dimensions.has_key? location.dimension
        dimensions[location.dimension].locations << location
        dimensions[location.dimension].episodes += location.episodes
      else
        dimensions[location.dimension] = Dimension.new location.dimension
        dimensions[location.dimension].locations << location
        dimensions[location.dimension].episodes = location.episodes
      end
    end
    sorted_dimensions = sort_dimensions(dimensions.values)
    sorted_dimensions.each do |dimension|
      sort_locations(dimension.locations)
    end

    sorted_dimensions.map {|dimension| dimension.locations}.flatten
  end

  def optimize(travel_plan : TravelPlan, locations : Array(Location), expand : Bool, optimize : Bool)
    if optimize
      locations = do_optimize locations
    end

    if expand
      travel_stops_expanded : Array(TravelStopExpanded) = locations.map { |location| TravelStopExpanded.new location }
      return TravelPlanExpanded.new(travel_plan.travel_plan_id, travel_stops_expanded)
    end
    return locations.empty? ? travel_plan : TravelPlan.new(travel_plan.travel_plan_id, locations.map { |location| location.id })
  end
end

class TravelPlanService
  repository : TravelPlanRepository
  optimizer : TravelPlanOptimizer

  def initialize(db_config : DbConfig)
    @repository = TravelPlanRepository.new db_config
    @optimizer = TravelPlanOptimizer.new
  end

  def get_all(expand : Bool, optimize : Bool)
    begin
      travel_plans = @repository.get_all
    rescue Exception
      raise Exception.new("Failed to get all from the database")
    else
      travel_plans.map do |travel_plan|
        locations = Array(Location).new

        if expand || optimize
          locations = travel_plan.travel_stops.map { |travel_stop| get_rick_and_morty_api_results travel_stop }
        end

        @optimizer.optimize(travel_plan, locations, expand, optimize)
      end
    end
  end

  def get_by_id(id : Int64 , expand : Bool , optimize : Bool)
    begin
      travel_plan = @repository.get_by_id(id)
    rescue Exception
      raise Exception.new("Failed to get from the database")
    else
      if travel_plan.travel_stops.size == 0
        raise NotFoundException.new(id)
      end

      locations = Array(Location).new

      if expand || optimize
        locations = travel_plan.travel_stops.map { |travel_stop| get_rick_and_morty_api_results travel_stop }
      end

      @optimizer.optimize(travel_plan, locations, expand, optimize)
    end
  end

  def save(travel_stops : Array(Int32))
    insert_id = @repository.save(travel_stops)

    if insert_id
      TravelPlan.new(insert_id, travel_stops)
    else
      raise Exception.new("Failed to insert into the database")
    end
  end

  def update(travel_plan : TravelPlan)
    @repository.update(travel_plan)
  end

  def delete(id : Int64)
    rs = @repository.delete(id)

    if rs.rows_affected == 0
      raise NotFoundException.new(id)
    end
  end
end
