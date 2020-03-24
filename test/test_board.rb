require 'minitest/autorun'
require 'rack/test'
require_relative '../engine/board'

class TestBoard < MiniTest::Test

  def setup
    @board = Board.new
    @board.add_player 'scott', 1
    @board.add_player 'sacks', 1    
  end
  
  def test_create_board
    assert_equal @board.players.count, 2
  end

  def test_start_game
    @board.start
  end

  def test_field
    @board.start
    assert_equal 10, @board.field.length
    
  end

  def test_red_cards
    @board.start
    @board.players[1].hand << Card.new(:sushi_bar)
    @board.current_turn.roll_one = 1
    @board.current_turn.roll_two = 0
    @board.run_turn
    assert_equal 1, @board.current_player.cash
  end
end
