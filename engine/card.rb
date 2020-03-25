class Card
  attr_accessor :name, :description, :cost, :active_numbers, :count, :value, :color, :symbol, :search_dict
  def initialize(name)
    base_card = Card.card_list[name]
    @name = name
    @description = base_card[0]
    @cost = base_card[1]
    @active_numbers = base_card[2]
    @value = base_card[3]
    @search_dict = base_card[4]
    @color = base_card[5]
    @symbol = base_card[6]
    @count = 1
  end

  def self.get_cards
    card_list.keys.map{|c| Card.new c}
  end

  def == other
    name.to_sym == other.name.to_sym
  end

  def to_s
    "#{count} #{name}.  Cost: $#{cost}.  Activates: #{active_numbers}"
  end

  def to_json
    {
      name: name,
      cost: cost,
      description: to_s,
      active_numbers: active_numbers,
      count: count
    }
  end

  private
  def self.card_list
    # description, cost, active numbers, value, search_dict, color, symbol
    {
      ranch: ['ranch', 1, [2], 1, {}, :blue, :cow],
      cheese_factory: ['cheese factory', 5, [7], 3, {symbol: :cow}, :green, :factory],
      flower_shop: ['flower shop', 1, [6], 1, {name: :flower_orchard}, :green, :store],
      convenience_store: ['convenience store', 2, [4], 3, {}, :green, :store],
      bakery: ["bakery", 1, [2,3], 1, {}, :green, :store],
      food_warehouse: ["food warehouse", 2, [12, 13], 2, {symbol: :cup}, :green, :factory],
      mine: ['mine', 6, [9], 5, {}, :blue, :gear],
      pizza_joint: ['pizza joint', 1, [7], 1, {}, :red, :cup],
      cafe: ['cafe', 2, [3], 1, {}, :red, :cup],
      business_center: ['business center', 8, [6], 0, {}, :purple, :tower],
      tv_station: ['tv station', 7, [6], 5, {}, :purple, :tower],
      flower_orchard: ['flower orchard', 2, [4], {}, :blue, :crop],
      publisher: ['publisher', 5, [7], 1, {}, :purple, :tower],
      stadium: ['stadium', 6, [6], 2, {}, :purple, :tower],
      family_restaurant: ['family restaurant', 3, [9, 10], {}, :red, :cup],
      mackerel_boat: ['mackerel boat', 2, [8], 3, {has: :harbor}, :blue, :boat],
      tax_office: ['tax office', 4, [8, 9], 0, {}, :purple, :tower],
      hamburger_stand: ['hamburger_stand', 1, [8], 1, {}, :red, :cup],
      sushi_bar: ["sushi bar", 4, [1], 3, {has: :harbor}, :red, :cup],
      wheat_field: ["wheat_field", 1, [1], 1, {}, :blue, :crop],
      tuna_boat: ['tuna boat', 7, [12, 13, 14], 0, {has: :harbor}, :blue, :boat],
      apple_orchard: ['apple orchard', 3, [10], 3, {}, :blue, :crop],
      forest: ['forest', 3, [5], 1, {}, :blue, :gear],
      furniture_factory: ['furniture_factory', 3, [8], 3, {symbol: :gear}, :green, :factory],
      fruit_market: ['fruit market', 2, [11, 12], 2, {symbol: :crop}, :green, :grenade]
    }
  end
end
