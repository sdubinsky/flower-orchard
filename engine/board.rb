require_relative 'card'
require_relative 'player'
require_relative 'turn'

class Board
  attr_accessor :players, :deck, :field, :started, :turnHistory, :current_player, :current_turn
  def initialize
    @players = []
    @deck = new_deck
    @field = []
    @started = false
    @turn_history = []
    @current_player = nil
  end

  def new_deck
    cards = []
    100.downto 0 do |x|
      cards << Card.new(x.to_s, x.to_s, x, [1,2], x)
    end
    cards
  end

  def start
    @started = true
    deal_field
    @current_player = players[0]
    @current_turn = Turn.new @current_player
  end

  def add_player name, id
    raise "game has already started" if started
    raise "already at max player count" if players.count >= 4
    players << Player.new(name, id)
  end

  def roll_dice dice_count
    @current_turn.roll_dice dice_count
  end

  def total
    @current_turn.roll_one + @current_turn.roll_two
  end

  def dice_display
    result = "#{current_turn.roll_one}"
    result += "::#{current_turn.roll_two}" if current_turn.dice_count == 2
    result
  end

  def run_turn
    dice_total = current_turn.roll_one + current_turn.roll_two
    dice_total += 2 if current_turn.add_two
    @current_player.activate_green_cards dice_total
  end

  def end_turn
    @players << @players.shift
    @current_player = @players[0]
    @turn_history << @current_turn
    @current_turn = Turn.new @current_player
  end

  def can_add_two?
    @current_turn.can_add_two
  end

  def can_roll_two?
    current_player.can_roll_two?
  end

  def buy_card card_name
    raise "please start game" if not @started
    card = field.find{|x| x.name.to_sym == card_name.to_sym}
    raise "couldn't find that card" if not card
    @current_player.buy_card card
    replace_in_field card
  end

  def activate_improvement improvement_name
    raise "please start game" if not @started
    @current_player.activate_improvement improvement_name
  end

  def replace_in_field card
    field_card = field.find{|x| x == card}
    field_card.count -= 1
    if field_card.count == 0
      field.delete(field_card)
      deal_field
    end
  end

  def deal_field
    while field.size < 10
      card = deck.pop
      if field.include? card
        field.find{|x| x == card}.count += 1
      else
        field << card
      end
    end
  end

  def to_s
    "Players: #{players.map{|s| s.to_s}}<br />Field: #{field.map{|f| f.to_s}}"
  end
end
