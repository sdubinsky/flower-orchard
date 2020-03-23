require 'minitest/autorun'
require 'rack/test'
require_relative '../engine/board'

class TestPlayer < MiniTest::Test
  def setup
    @player = Player.new 'scott', 1
    @other_player = Player.new 'sacks', 1
  end

  def test_add_green_cards_adds_total
    @player.activate_green_cards 2
    assert_equal @player.cash, 4
  end

  def test_add_green_cards_only_on_roll
    @player.activate_green_cards 1
    assert_equal @player.cash, 3
  end

  def test_buy_card
    
  end
end
