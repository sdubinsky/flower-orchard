class Card
  attr_accessor :name, :description, :cost, :active_numbers, :count, :value, :color
  def initialize(name, description, cost, active_numbers, value, color)
    @name = name
    @description = description
    @cost = cost
    @active_numbers = active_numbers
    @count = 1
    @value = value
    @color = color
  end

  def == other
    name.to_sym == other.name.to_sym
  end

  def to_s
    "name: #{name}.  Cost: $#{cost}"
  end
end
