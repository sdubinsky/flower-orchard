require 'json'
require_relative 'card'
require_relative 'player'
require_relative 'turn'

class Board
  attr_accessor :players, :deck, :field, :started, :turnHistory, :current_turn, :commands
  def initialize
    @players = []
    @commands = []
    @log = []
    @deck = new_deck
    @field = []
    @started = false
    @turn_history = []
    @current_player = nil
  end

  def new_deck
    cards = []
    5.times do
      cards += Card.get_cards Card.regular_card_list
    end
    @players.count.times do 
      cards += Card.get_cards Card.purple_card_list
    end
    cards.shuffle
  end

  def start
    @started = true
    deal_field
    @current_player = 0
    @current_turn = Turn.new current_player
  end

  def current_player
    @players[@current_player]
  end

  def add_player name, id
    raise "game has already started" if started
    raise "already at max player count" if players.count >= 4
    @log.append "added player #{name}"
    players << Player.new(name, id)
  end

  def roll_dice dice_count
    @current_turn.roll_dice dice_count
    @log.append "rolled: #{dice_display}"
    if dice_count == 1 or (!can_add_two? and !can_roll_again?)
      run_turn
    end
  end

  def total
    @current_turn.roll_one + @current_turn.roll_two
  end

  def dice_display
    result = "#{current_turn.roll_one}"
    result += " :: #{current_turn.roll_two}" if current_turn.dice_count == 2
    result
  end

  def run_turn
    return if @current_turn.paid_out
    dice_total = current_turn.roll_one + current_turn.roll_two
    dice_total += 2 if current_turn.add_two
    @log.append current_player.activate_green_cards dice_total
    @players.each{|p| @log.append p.activate_blue_cards dice_total}
    @players.each do |p|
      if p != current_player
        fine = p.activate_red_cards dice_total
        charge = current_player.pay fine
        p.cash += charge
        @log.append "#{current_player.name} got $#{charge} from #{p.name}" if fine > 0
      end
    end
    if current_player.cash == 0
      current_player.cash += 1
      @log.append "#{current_player.name} got their pity coin"
    end
    @current_turn.paid_out = true
  end

  def end_turn
    if !(current_turn.roll_one == current_turn.roll_two and
      current_player.can_roll_again?)
      @current_player = (@current_player + 1) % @players.length
      @turn_history << @current_turn
      @log.append "#{current_player.name}'s turn"
    else
      @log.append "#{current_player.name} got another turn"
    end
    @current_turn = Turn.new current_player
  end

  def can_add_two?
    @current_turn.can_add_two? and current_player.can_add_two? and not @current_turn.add_two
  end

  def can_roll_two?
    current_player.can_roll_two?
  end

  def can_roll_again?
    current_turn.rolls < 2 and current_player.can_roll_again?    
  end

  def buy_card card_name
    raise "please start game" if not @started
    card = field.find{|x| x.name.to_sym == card_name.to_sym}
    raise "couldn't find that card" if not card
    current_player.buy_card card.name
    @log.append "#{current_player.name} bought #{card.name}"
    replace_in_field card
    @current_turn.bought = true
  end

  def activate_improvement improvement_name
    raise "please start game" if not @started
    current_player.activate_improvement improvement_name
    @log.append "#{current_player.name} activated #{improvement_name}"
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
        @log.append "added #{card.name} to the field"
        field << card
      end
    end
  end

  def to_s
    "Players: #{players.map{|s| s.to_s}}<br />Field: #{field.map{|f| f.to_s}}"
  end

  def to_json
    {
      current_player: current_player.to_json,
      players: players.map{|a| a.to_json},
      field: field.map{|f| f.to_json},
      current_turn: current_turn.to_json,
      can_roll_two: can_roll_two?,
      can_roll_again: can_roll_again?,
      log: @log.last(10).reverse
    }.to_json
  end
end
