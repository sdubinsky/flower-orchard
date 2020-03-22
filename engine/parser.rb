module Parser
  def self.parse command, board
    tokens = command.split
    head = tokens.shift
    case head
    when 'add'
      parse_add_player tokens, board
    when 'start'
      parse_start tokens, board
    when "run"
      parse_run tokens, board
    when 'end_turn'
      parse_end_turn tokens, board
    when 'buy'
      parse_buy tokens, board
    when 'roll'
      parse_roll tokens, board
    else
      raise 'invalid command'
    end
  end

  def self.parse_add_player tokens, board
    board.add_player tokens.shift, 1
  end

  def self.parse_start tokens, board
    board.start
  end

  def self.parse_run tokens, board
    board.run_turn
  end

  def self.parse_end_turn tokens, board
    board.end_turn
  end
  
  def self.parse_buy tokens, board
    command = tokens.shift
    case command
    when 'card'
      board.buy_card tokens[-1]
    when 'improvement'
      board.buy_improvement tokens[-1]
    else
      raise "invalid buy command"
    end
  end

  def self.parse_roll tokens, board
    command = tokens.shift
    case command
    when 'one'
      board.roll_dice 1
    when 'two'
      raise "can't roll two dice" if !board.can_roll_two?
      board.roll_dice 2
    else
      raise 'invalid roll command'
    end
  end
end
