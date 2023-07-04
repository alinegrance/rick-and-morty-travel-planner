# TODO: Write documentation for `Milenio::Challenge`
require "kemal"
require "./controllers/travel_plans.cr"

module Milenio::Challenge
  VERSION = "0.1.0"

  Kemal.run
end
