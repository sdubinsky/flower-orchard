require 'json'
require_relative 'card'
require_relative 'player'
require_relative 'turn'
require 'pry-byebug'

class Board
  attr_accessor :players, :deck, :field, :started, :turnHistory, :current_turn, :commands, :game_over, :tv_station, :business_center
  def initialize
    @players = []
    @commands = []
    @log = []
    @deck = []
    @field = []
    @started = false
    @turn_history = []
    @current_player = nil
    @game_over = false
    @tv_station = false
    @business_center = false
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
    @deck = new_deck
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
    check_specials total
    @log.append current_player.activate_green_cards dice_total
    @players.each{|p| @log.append p.activate_blue_cards dice_total}
    @players.each do |p|
      if p != current_player
        fine = p.activate_red_cards dice_total
        charge = current_player.pay fine
        p.cash += charge
        @log.append "#{p.name} got $#{charge} from #{current_player.name}" if fine > 0
      end
    end
    if current_player.cash == 0
      current_player.cash += 1
      @log.append "#{current_player.name} got their pity coin"
    end
    @current_turn.paid_out = true
  end

  def end_turn
    if tv_station or business_center
      return
    end
    check_game_over
    if game_over
      return
    end
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
    current_turn.rolls == 1 and current_player.can_roll_again?
  end

  def check_specials total
    tax_office = current_player.hand.find{|x| x.name == :tax_office}
    if tax_office and tax_office.active_numbers.include? total
      @tax_office = true
    end

    business_center = current_player.hand.find{|x| x.name == :business_center}
    if business_center and business_center.active_numbers.include? total
      @business_center = true
    end
  end

  def use_tv_station target
    return if not @tv_station
    target = players.find{|a| a.name == target}
    if target == current_player
      @log.append "can't target current player"
      return
    end
    fine = 5
    if target.cash < 5
      fine = target.cash
    end
    @log.append "#{current_player.name} got #{fine} from #{target.name} through a tv station"
    target.cash -= fine
    current_player.cash += fine
    @tv_station = false
  end

  def use_business_center my_card, target, their_card
    return if not @business_center
    target = players.find{|a| a.name == target}
    my_card = current_player.hand.find{|a| a.name == my_card.to_sym}
    their_card = target.hand.find{|a| a.name == their_card.to_sym}
    if my_card.count == 1
      current_player.hand.delete(my_card)
    else
      my_card.count -= 1
    end
    if their_card.count == 1
      target.hand.delete(their_card)
    else
      their_card.count -= 1
    end
    current_player.add_card Card.new(their_card.name)
    target.add_card Card.new(my_card.name)
    @business_center = false
  end

  def buy_card card_name
    raise "please start game" if not @started
    if card_name == 'pass'
      @log.append "#{current_player.name} passed."
      if current_player.gets_free_money?
        current_player.cash += 10
        @log.append "#{current_player.name} gets 10 from the airport"
      end
      return
    end
    card = field.find{|x| x.name.to_sym == card_name.to_sym}
    raise "couldn't find that card" if not card
    current_player.buy_card card_name.to_sym
    @log.append "#{current_player.name} bought #{card_name}"
    replace_in_field card
    @current_turn.bought = true
  end

  def activate_improvement improvement_name
    raise "please start game" if not @started
    current_player.activate_improvement improvement_name
    @log.append "#{current_player.name} activated #{improvement_name}"
  end

  def check_game_over
    @game_over = current_player.has_won?
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
      log: @log.last(10).reverse,
      business_center: @business,
      tv_station: @tv_station,
      game_over: @game_over
    }.to_json
  end
end
