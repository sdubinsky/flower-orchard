class Card
  attr_accessor :name, :description, :cost, :active_numbers, :count, :value, :color
  def initialize(name)
    base_card = card_list[name]
    @name = name
    @description = base_card[0]
    @cost = base_card[1]
    @active_numbers = base_card[2]
    @value = base_card[3]
    @color = base_card[4]
    @count = 1
  end

  def == other
    name.to_sym == other.name.to_sym
  end

  def to_s
    "name: #{name}.  Cost: $#{cost}"
  end

  def to_json
    {
      name: name,
      cost: cost,
      description: to_s      
    }
  end

  private
  def card_list
    # description, cost, active numbers, value, color
    {
      wheat: ["wheat", 1, [1], 1, :blue],
      bakery: ["bakery", 1, [2,3], 1, :green],
      sushi_bar: ["sushi bar", 4, [1], 3, :red],
      stadium: ['stadium', 5, [6], 5, :purple]
    }
  end
end
