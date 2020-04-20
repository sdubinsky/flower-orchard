require 'sinatra'
require 'sequel'
require 'logger'
require './engine/board'
require './helpers'
require 'pry'
require 'pry-byebug'

connstr = ENV['DATABASE_URL'] || "postgres://localhost/machikoro"
DB = Sequel.connect connstr
require './models/init'

include Helpers
enable :sessions
logger = Logger.new $stdout
logger.level = Logger::INFO
configure :development do
  set :show_exceptions, true
  logger = Logger.new $stdout
  logger.level = Logger::DEBUG
end

get '/' do
  erb :index
end

get '/create_game/?' do
  erb :create_game
end

post '/game/create/?' do
  board = Board.new
  Game.create(
    name: params['gamename'],
    board: Marshal.dump(board)
  )
  redirect "/games"
end

get '/games/?' do
  @games = Game.all
  erb :games
end

get '/game/:game_id/start/?' do
  logger.info "starting game #{params['game_id']}"
  @game = Game[params['game_id'].to_i]
  @board = Marshal.load @game.board
  @board.start
  @game.board = Marshal.dump @board
  @game.save
  redirect "/game/#{params['game_id']}"
end

get '/game/:game_id/?' do
  @game = Game[params['game_id'].to_i]
  @board = Marshal.load @game.board
  if @board.started
    erb :game
  else
    erb :pregame
  end
end

post '/game/:game_id/addplayer' do
  logger.info "adding player #{params["playername"]}"
  player = params["playername"]
  @game = Game[params['game_id'].to_i]
  @board = Marshal.load(@game.board)
  begin
    @board.add_player player, 1
  rescue => e
    @error_message = e.message
  end
  @game.board = Marshal.dump @board
  @game.save
  redirect "/game/" + params["game_id"]
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
#10. figure out a query syntax for cards that depend on other cards to figure out how much they are.
#      Something like: if it's an empty dict, just do that.  if it's a dict, search based on the dict, and multiply that total by the value. dict syntax: {search_term: value}.  Examples: {color: red}, {symbol: :factory}, {name: :flower_orchard}
#11. purple cards.  Probably a special method for each one.
#        [X] stadium(2 from all)
#        [X] tv station(five from one)]
#        [X] business center(trade establishments)
#        [X] publisher(take one from everyone for each cup and toast)
#        [ ] tax office(half rounded down from everyone with 10 or more coins)
#12. if I accept a roll, it shouldn't still display the roll buttons.
