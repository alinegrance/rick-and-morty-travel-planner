class DbConfig
  property host : String
  property port : String
  property user : String
  property password : String
  property driver : String
  property database : String

  def initialize
    @host = (ENV.has_key? "DB_HOST") ? ENV["DB_HOST"] : "db"
    @port = (ENV.has_key? "DB_PORT") ? ENV["DB_PORT"] : "3306"
    @user = (ENV.has_key? "DB_USER") ? ENV["DB_USER"] : "root"
    @password = (ENV.has_key? "DB_PASSWORD") ? ENV["DB_PASSWORD"] : "password"
    @driver = (ENV.has_key? "DB_DRIVER") ? ENV["DB_DRIVER"] : "mysql"
    @database = (ENV.has_key? "DB_DATABASE") ? ENV["DB_DATABASE"] : "rick_and-morty_development"
  end
end
