class Turn
  attr_accessor :roll_one, :roll_two, :dice_count, :player, :add_two, :rolls, :paid_out, :bought
  def initialize current_player
    @player = current_player
    @dice_count = 1
    @add_two = false
    @rolls = 0
    @paid_out = false
    @bought = false
  end

  def roll_dice dice_count
    @rolls += 1
    @dice_count = dice_count
    @roll_one = rand(5) + 1
    if dice_count == 2
      @roll_two = rand(5) + 1
    else
      @roll_two = 0
    end
  end

  def can_add_two?
    (roll_one + roll_two) >= 10
  end

  def repeat?
    @roll_one == @roll_two
  end

  def to_json
    {
      roll_one: @roll_one || -1,
      roll_two: @roll_two || -1,
      rolls: @rolls,
      paid_out: @paid_out,
      dice_count: @dice_count
    }
  end
end
