require_relative 'card'
require_relative 'improvement'

class Player
  attr_accessor :name, :improvements, :hand, :cash
  def initialize(name)
    @name = name
    @cash = 3
    @improvements = initial_improvements
    @hand = initial_hand
  end

  def initial_hand
    [
      Card.new(:wheat, "wheat", 3, [1]),
      Card.new(:bakery, "bakery", 1, [2, 3])
    ]
  end

  def initial_improvements
    [
      Improvement.new(:harbor, 'harbor', 2)
    ]
  end

  def get_more_cash total
    cash += hand.
              filter{|x| x.active_numbers.include? total}.
              map{|x| x.value * x.count}.
              reduce(:+)
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
    cash -= card.cost
  end

  def activate_improvement name
    improvement = improvements.find{|a| a.name == name}
    raise "not enough money" if improvement.cost > cash
    improvement.activate
  end
end
