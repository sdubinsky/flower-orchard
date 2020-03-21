#\ -p 4567
require './app'
require './middlewares/websocket'

use GameUpdates::UpdatesBackend

$stdout.sync = true
run Sinatra::Application
