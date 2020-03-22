require 'minitest/autorun'
require 'rack/test'
require_relative '../engine/board'
require_relative '../engine/parser'

class TestParser < MiniTest::Test
  include Parser
  def setup
    
    @board = Board.new    
  end

  def test_sample_turn
    Parser.parse "add scott", @board
    Parser.parse "add sacks", @board
    assert_equal 2, @board.players.count
    Parser.parse "start", @board
    assert @board.current_player
    Parser.parse "roll one", @board
    @board.current_turn.roll_one = 1
    Parser.parse "run", @board
    assert_equal @board.current_player.cash, 4
    Parser.parse "buy card wheat", @board
    assert_equal @board.current_player.cash, 3
    player = @board.current_player
    Parser.parse "end_turn", @board
    refute_equal player, @board.current_player
  end
end