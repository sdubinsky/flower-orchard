require 'faye/websocket'
Faye::WebSocket.load_adapter('thin')

module GameUpdates
  class UpdatesBackend
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app = app
      @clients = []
    end

    def call env
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new env, nil, {ping: KEEPALIVE_TIME}
        ws.on :open do |event|
          @clients << ws
        end

        ws.on :message do |event|
          new_board = @app.update_board event.data
          @clients.each {|c| c.send new_board}
        end

        ws.on :close do |event|
          @clients.delete ws
        end
        ws.rack_response
      else
        @app.call env
      end
    end
  end
end
