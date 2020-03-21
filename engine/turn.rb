class Turn
  attr_accessor :roll_one, :roll_two, :dice_count, :player, :add_two, :rolled
  def initialize current_player
    @player = current_player
    @dice_count = 1
    @add_two = false
    @rolled = false
  end

  def roll_dice dice_count
    @rolled = true
    @dice_count = dice_count
    @roll_one = rand(5) + 1
    if dice_count == 2
      @roll_two = rand(5) + 1
    else
      @roll_two = 0
    end
  end

  def can_add_two
    (roll_one + roll_two) >= 10
  end

  def repeat?
    @roll_one == @roll_two
  end

  def to_json
    {
      roll_one: @roll_one || -1,
      roll_two: @roll_two || -1,
      rolled: @rolled,
      dice_count: @dice_count
    }
  end
end
