require "../spec_helper"
require "../../src/services/travel_plan.cr"
require "../../src/models/location.cr"
require "../../src/models/travel_plan.cr"

describe "PlanTravelOptimizerTest" do
  optimizer = TravelPlanOptimizer.new
  travel_plan = TravelPlan.new(1, [1, 2, 3])

  it "returns the locations not expanded and in the same order" do
    locations = Array(Location).new

    travel_plan_optimized = optimizer.optimize(travel_plan, locations, false, false)

    travel_plan_optimized.travel_plan_id.should eq 1
    travel_plan_optimized.travel_stops.should eq [1, 2, 3]
  end

  it "returns the locations expanded but not optimized" do
    location1 = Location.new(1, "planet1", "planet", "dimension1", 10)
    location2 = Location.new(2, "planet2", "planet", "dimension2", 20)
    location3 = Location.new(3, "planet3", "planet", "dimension3", 30)

    locations = [location1, location2, location3]
    travel_stop_expanded = locations.map { |location| TravelStopExpanded.new location }

    travel_plan_expanded = optimizer.optimize(travel_plan, locations, true, false)

    travel_plan_expanded.is_a? TravelPlanExpanded
    travel_plan_expanded.travel_plan_id.should eq 1
    travel_plan_expanded.travel_stops.size.should eq 3

    travel_plan_expanded.travel_stops.as(Array(TravelStopExpanded)).zip locations, do |travel_stop, location|
      travel_stop.is_a? TravelStopExpanded
      travel_stop.id.should eq location.id
      travel_stop.name.should eq location.name
      travel_stop.type.should eq location.type
      travel_stop.dimension.should eq location.dimension
    end
  end

  it "returns the locations optimized but not expanded" do
    location2 = Location.new(2, "Abadango", "planet", "unknown", 1)
    location7 = Location.new(7, "Immortality Field Resort", "planet", "unknown", 7)
    location9 = Location.new(9, "Purge Planet", "planet", "Replacement Dimension", 4)
    location11 = Location.new(11, "Bepis 9", "planet", "unknown", 4)
    location19 = Location.new(19, "Gromflom Prime", "planet", "Replacement Dimension", 0)

    locations = [location2, location7, location9, location11, location19]
    expected_location_ids = [19, 9, 2, 11, 7]

    travel_plan_optimized = optimizer.optimize(travel_plan, locations, false, true)

    travel_plan_optimized.is_a? TravelPlan
    travel_plan_optimized.travel_plan_id.should eq 1
    travel_plan_optimized.travel_stops.size.should eq 5

    travel_plan_optimized.travel_stops.zip expected_location_ids, do |travel_stop, expected_location_id|
      travel_stop.is_a? Int32
      travel_stop.should eq expected_location_id
    end
  end

  it "returns the locations expanded and optimized" do
    location2 = Location.new(2, "Abadango", "planet", "unknown", 1)
    location7 = Location.new(7, "Immortality Field Resort", "planet", "unknown", 7)
    location9 = Location.new(9, "Purge Planet", "planet", "Replacement Dimension", 4)
    location11 = Location.new(11, "Bepis 9", "planet", "unknown", 4)
    location19 = Location.new(19, "Gromflom Prime", "planet", "Replacement Dimension", 0)

    locations = [location2, location7, location9, location11, location19]
    expected_locations = [location19, location9, location2, location11, location7]
    expected_travel_stop_expanded = expected_locations.map { |expected_location| TravelStopExpanded.new expected_location }

    travel_plan_optimized = optimizer.optimize(travel_plan, locations, true, true)

    travel_plan_optimized.is_a? TravelPlanExpanded
    travel_plan_optimized.travel_plan_id.should eq 1
    travel_plan_optimized.travel_stops.size.should eq 5

    travel_plan_optimized.travel_stops.as(Array(TravelStopExpanded)).zip expected_travel_stop_expanded, do |travel_stop, travel_stop_expanded|
      travel_stop.is_a? TravelStopExpanded
      travel_stop.id.should eq travel_stop_expanded.id
      travel_stop.name.should eq travel_stop_expanded.name
      travel_stop.type.should eq travel_stop_expanded.type
      travel_stop.dimension.should eq travel_stop_expanded.dimension
    end
  end
end
