class NotFoundException < Exception
  property id : Int64

  def initialize(id)
    @id = id
  end
end
