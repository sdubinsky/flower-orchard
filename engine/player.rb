require_relative 'card'
require_relative 'improvement'

class Player
  attr_accessor :name, :id, :improvements, :hand, :cash
  def initialize(name, id)
    @name = name
    @id = id
    @cash = 3
    @improvements = initial_improvements
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
      Improvement.new(:harbor, 'harbor', 2)
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
      map{|x| x.value * x.count}.
      reduce(0, :+)
  end

  def can_roll_two?
    improvements.find{|a| a.name == :harbor}.active
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
    improvement = improvements.find{|a| a.name == name}
    raise "not enough money" if improvement.cost > cash
    improvement.activate
  end

  def to_s
    "#{name}: $#{cash} on hand."
  end
end
