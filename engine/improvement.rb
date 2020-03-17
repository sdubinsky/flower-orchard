class Improvement
  attr_accessor :name, :description, :cost, :active
  def initialize(name, description, cost)
    @name = name
    @description = description
    @cost = cost
    @active = false
  end

  def == other
    name.to_sym == other.to_sym
  end
end
