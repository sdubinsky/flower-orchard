require_relative 'card'
class Board
  attr_accessor :players, :deck, :field, :started, :turnHistory, :current_player
  def initialize
    @players = []
    @deck = new_deck
    @field = deal_field @deck
    @started = false
    @turn_history = []
    @current_player = nil
  end

  def new_deck
    cards = []
    100.times do |x|
      cards << Card.new(x.to_s, x.to_s, x)
    end
    cards
  end

  def start
    @started = true
    @current_player = players[0]
  end

  def add_player name, id
    raise "game has already started" if started
    raise "already at max player count" if players.count >= 4
    players << Player.new(name, id)
  end

  def can_roll_two?
    current_player.can_roll_two?
  end

  def buy_card card
    raise "please start game" if not @started
    @current_player.buy_card card
  end

  def activate_improvement improvement_name
    raise "please start game" if not @started
    @current_player.activate_improvement improvement_name
  end

  def deal_field
    field = []
    while field.size < 10
      card = deck.pop
      if field.include? card
        field.find{|x| x == card}.count += 1
      else
        field << card
      end
    end
  end
end
