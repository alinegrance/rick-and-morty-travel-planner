require "mysql"
require "../models/travel_plan.cr"

class TravelPlanRepository
  @conn : DB::Connection

  def initialize(db_config : DbConfig)
    host = db_config.host
    port = db_config.port
    user = db_config.user
    password = db_config.password
    driver = db_config.driver
    database = db_config.database

    @conn = DB.connect "#{driver}://#{user}:#{password}@#{host}:#{port}/#{database}"
  end

  def save(travel_stops : Array(Int32))
    @conn.transaction do |tx|
      conn2 = tx.connection
      result = conn2.exec("INSERT INTO travel_plans (created_at, updated_at) VALUES (?,?)", Time.utc, Time.utc)
      insert_id = result.last_insert_id

      travel_stops.each do |travel_stop|
        conn2.exec("INSERT INTO travel_legs (travel_plan_id, travel_stop_id) VALUES (?,?)", insert_id, travel_stop)
      end
      insert_id
    end
  end

  def get_all
    travel_dict = {} of Int32 => Array(Int32)

    @conn.query("SELECT travel_plan_id, travel_stop_id FROM travel_legs") do |rs|
      rs.each do

        travel_plan_id = rs.read(Int32)
        travel_stop_id = rs.read(Int32)

        travel_stops = travel_dict.fetch(travel_plan_id, [] of Int32)
        travel_stops << travel_stop_id

        travel_dict[travel_plan_id] = travel_stops

      end
    end

    travel_plans = [] of TravelPlan
    travel_dict.each do |travel_plan_id, travel_stops|
      travel_plans << TravelPlan.new(travel_plan_id, travel_stops)
    end

    return travel_plans
  end

  def get_by_id(travel_plan_id : Int64)
    travel_stops = [] of Int32
    @conn.query("SELECT travel_plan_id, travel_stop_id FROM travel_legs WHERE travel_plan_id = ?", travel_plan_id) do |rs|
      rs.each do
        travel_plan_id = rs.read(Int32)
        travel_stop_id = rs.read(Int32)

        travel_stops << travel_stop_id
      end
    end
    return TravelPlan.new(Int64.new(travel_plan_id), travel_stops)
  end

  def update(travel_plan : TravelPlan)
    @conn.transaction do |tx|
      conn2 = tx.connection
      conn2.exec("DELETE FROM travel_legs WHERE travel_plan_id = ?", travel_plan.travel_plan_id)

      travel_plan.travel_stops.each do |travel_stop|
        conn2.exec("INSERT INTO travel_legs (travel_plan_id, travel_stop_id) VALUES (?,?)", travel_plan.travel_plan_id, travel_stop)
      end

      conn2.exec("UPDATE travel_plans SET updated_at = ? WHERE id = ?", Time.utc, travel_plan.travel_plan_id)
    end
  end

  def delete(travel_plan_id : Int64)
    @conn.exec("DELETE FROM travel_plans WHERE id = ?", travel_plan_id)
  end
end
