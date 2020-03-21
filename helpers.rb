module Helpers
  def update_board id
    @game = Game[id.to_i]
    @board = Marshal.load(@game.board)
    @board.to_json
  end
end
