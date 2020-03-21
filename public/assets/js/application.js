var scheme = "ws://";
var uri = scheme + window.document.location.host + window.document.location.pathname + "/";
var ws = new WebSocket(uri);



ws.onmessage = function(message) {
    var board = JSON.parse(message.data);
    var players_div = document.querySelector('#players');
    players_div.innerHTML = "";
    board.players.forEach(function(player){
        players_div.innerHTML += "<div class='player-name'>" + player + "</div><br />";
    });
    document.querySelector('#current-player').innerHTML = "current player: " + board.current_player;
};
