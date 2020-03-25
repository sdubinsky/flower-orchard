require_relative 'card'
require_relative 'improvement'

class Player
  attr_accessor :name, :id, :improvements, :hand, :cash
  def initialize(name, id)
    @name = name
    @id = id
    @cash = 3
    @improvements = initial_improvements
    @improvements[0].active = true
    @hand = initial_hand
  end

  def initial_hand
    [
      Card.new(:wheat_field),
      Card.new(:bakery)
    ]
  end

  def initial_improvements
    [
      Improvement.new(:city_hall, 'city hall', 0),
      Improvement.new(:harbor, 'harbor', 2),
      Improvement.new(:train_station, 'train station', 4),
      Improvement.new(:shopping_mall, 'shopping mall', 10),
      Improvement.new(:amusement_park, 'amusement park', 16),
      Improvement.new(:radio_tower, 'radio tower', 22),
      Improvement.new(:airport, 'airport', 30)
    ]
  end

  def activate_green_cards total
    @cash += activate_cards :green, total
  end

  def activate_blue_cards total
    @cash += activate_cards :blue, total
  end

  def activate_red_cards total
    activate_cards :red, total   
  end

  def activate_purple_cards total
    activate_cards :purple, total
  end

  def pay total
    '''
    the game will get how much to charge for the red cards from the other players,
    then charge the active player that amount
    '''
    if @cash <= total
      to_pay = cash
      @cash = 0
    else
      @cash -= total
      to_pay = total
    end
    to_pay
  end

  def activate_cards color, total
    hand.
      select { |x| x.color == color }.
      select{|x| x.active_numbers.include? total}.
      map{|x| get_card_value(x) * x.count}.
      reduce(0, :+)
  end

  def get_card_value card
    if improvements.find{|i| i.name == :shopping_mall}.active and
      (card.symbol == :cup or card.symbol == :shop)
      value = card.value + 1
    else
      value = card.value
    end
    card.search_dict.each do |k, v|
      case k
      when :has
        return 0 unless improvements.find{|a| a.name == v}
      when :name
        return value * cards.
                         select{|c| c.name == v}.
                         map{|c| c.count}.
                         reduce(0, :+)
      when :symbol
        return value * cards.
                         select{|c| c.symbol == v}.
                         map{|c| c.count}.
                         reduce(0, :+)
      else
        puts "invalid search type #{k}"
      end
    end
    value
  end

  def can_roll_two?
    improvements.find{|a| a.name == :train_station}.active
  end

  def can_add_two?
    improvements.find{|a| a.name == :harbor}.active
  end

  def can_roll_again?
    improvements.find{|a| a.name == :amusement_park}.active
  end

  def gets_free_money?
    improvements.find{|a| a.name == :airport}.active
    
  end

  def buy_card card
    raise "not enough money" if card.cost > @cash
    if hand.include? card
      hand.find{|x| x == card}.count += 1
    else
      hand << card
    end
    @cash -= card.cost
  end

  def activate_improvement name
    improvement = improvements.find{|a| a.name == name.to_sym}
    raise "invalid improvement name" if not improvement
    raise "not enough money" if improvement.cost > cash
    raise "already activated" if improvement.active
    improvement.active = true
  end

  def to_s
    "#{name}: $#{cash} on hand."
  end

  def to_json
    {
      name: @name,
      hand: hand.map{|h| h.to_json},
      improvements: improvements.map{|h| h.to_json},
      cash: cash
    }
  end
end
