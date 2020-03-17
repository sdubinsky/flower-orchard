require 'sinatra'
require 'sequel'
require 'engine/board'
require 'models/init'

enable :sessions
get '/' do
  erb :index
end

post '/game/create/:name/?' do
  board = Board.new
  game = Game.create(
    name: params['name'],
    board: Marshal.dump(board)
  )
end

post '/game/join' do
  player = User[session['user_id'].to_i]
  @game = Game[params['game_id'].to_i]
  @board = Marshal.load(game.board)
  @board.add_player player.name, player.id
end



get '/games/?/:game_id?/?' do
  @game = Game[params['game_id'].to_i]
  @board = Marshal.load(game.board)
  erb :game
end

#TODO:
#1. add Player model/migration
#2. add tests for adding players to a game
#3. add start game button
#4. add concept of a turn to the game
#5. figure out dice rolls???
#6. test through an entire basic turn
#7. add blue cards/the concept of different card colors
#8. add red cards/the concept of money moving from player to player
#    instead of a "get_more_cash" method, we have one method per card color.  The game knows to call green only on the active player, blue on all players, red only on other players(and to ding the active player in order), and purple on the active player(and to ding the other players).  Also need to add a charge method.
#9. figure out a reliable way to incorporate improvements
#    each method should check if the relevant improvement is active.  What to do about rolling one/two dice?  What to do about taking another turn?  What to do about the airport?

