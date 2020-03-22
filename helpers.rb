require 'json'
require_relative "./engine/parser"
module Helpers
  def update_board message
    data = JSON.parse message
    @game = Game[data['game_id'].to_i]
    @board = Marshal.load(@game.board)
    Parser.parse data['message'], @board
    @game.board = Marshal.dump @board
    @game.save
    @board.to_json
  end
end
