require "env"
require "json"
require "kemal"
require "mysql"
require "../config/db_config.cr"
require "../services/travel_plan.cr"

db_config = DbConfig.new
service = TravelPlanService.new db_config

post "/travel_plans" do |env|
  travel_stops = Array(Int32).from_json env.params.json["travel_stops"].to_s

  env.response.content_type = "application/json"

  begin
    new_travel_stops = service.save(travel_stops)
  rescue ex : Exception
    env.response.status_code = 500
    {:error => ex.message}.to_json
  else
    env.response.status_code = 201
    new_travel_stops.to_json
  end
end

get "/travel_plans" do |env|
  expand = (env.params.query.has_key? "expand") ? (env.params.query["expand"] == "true") : false
  optimize = (env.params.query.has_key? "optimize") ? (env.params.query["optimize"] == "true") : false

  env.response.content_type = "application/json"

  begin
    response = service.get_all(expand, optimize)
  rescue ex : Exception
    env.response.status_code = 500
    {:error => ex.message}.to_json
  else
    env.response.status_code = 200
    response.to_json
  end
end

get "/travel_plans/:id" do |env|
  id = Int64.new(env.params.url["id"])

  expand = (env.params.query.has_key? "expand") ? (env.params.query["expand"] == "true") : false
  optimize = (env.params.query.has_key? "optimize") ? (env.params.query["optimize"] == "true") : false

  env.response.content_type = "application/json"

  begin
    travel_plan = service.get_by_id(id, expand, optimize)
  rescue ex : NotFoundException
    env.response.status_code = 404
    {:error => "Failed to get id #{ex.id}"}.to_json
  rescue ex : Exception
    env.response.status_code = 500
    {:error => "Failed to get from the database"}.to_json
  else
    env.response.status_code = travel_plan.travel_stops.size == 0 ? 404 : 200
    travel_plan.to_json
  end
end

put "/travel_plans/:id" do |env|
  id = Int64.new(env.params.url["id"])
  travel_stops = Array(Int32).from_json env.params.json["travel_stops"].to_s

  env.response.content_type = "application/json"

  begin
    service.update(TravelPlan.new(id, travel_stops))
  rescue Exception
    env.response.status_code = 404
    {:error => "Failed to update id #{id}"}.to_json
  else
    env.response.status_code = 200
    {"id" => id, "travel_stops" => travel_stops}.to_json
  end
end

delete "/travel_plans/:id" do |env|
  id = Int64.new(env.params.url["id"])

  env.response.content_type = "application/json"

  begin
    service.delete(id)
  rescue ex : NotFoundException
    env.response.status_code = 404
  else
    env.response.status_code = 204
  end
end

error 404 do
  {:message => "Travel plan not found"}.to_json
end
