var scheme = "ws://";
var uri = scheme + window.document.location.host + window.document.location.pathname + "/";
var ws = new WebSocket(uri);

var getGameId = function(){
    var game_id = window.document.location.pathname.split("/");
    game_id = game_id[game_id.length - 1];
    return game_id;
};

var displayBoard = function(board) {
    var players_div = document.querySelector('#players');
    players_div.innerHTML = "";
    board.players.forEach(function(player){
        let elem = document.createElement("div");
        elem.innerHTML = player;
        players_div.appendChild(elem);
    });
    var field_div = document.querySelector("#field");
    field_div.innerHTML = "";
    board.field.forEach(function(card){
        let elem = document.createElement("div");
        elem.onclick = function (event){
            ws.send(JSON.stringify({'game_id': getGameId(), 'message': "buy card " + card.name}));
        };
        elem.innerHTML = card.description;
        field_div.appendChild(elem);
    });
    var pay_out = document.querySelector("#pay-out");
    pay_out.innerHTML = "";

    document.querySelector('#current-player').innerHTML = "current player: " + board.current_player;
    if (!board.current_turn.rolled){
        var pass = document.querySelector("#pass");
        pass.innerHTML = "";
        var dice_one = document.querySelector("#diceone");
        dice_one.innerHTML = "";
        var dice_two = document.querySelector("#dicetwo");
        dice_two.innerHTML = "";
        var roll_one = document.createElement("div");
        roll_one.onclick = function (event) {
            ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'roll one'}));
        };
        roll_one.innerHTML = "Roll One";
        var roll_two = document.createElement("div");
        roll_two.onclick = function (event) {
            ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'roll two'}));
        };
        roll_two.innerHTML = "Roll Two";
        var rolldice = document.querySelector("#rolldice");
        rolldice.innerHTML = "";
        rolldice.appendChild(roll_one);
        if (board.can_roll_two){
            rolldice.appendChild(roll_two);
        }
    }
    if (board.current_turn.rolled){
        var rolldice = document.querySelector("#rolldice");
        rolldice.innerHTML = "";
        var dice_one = document.querySelector("#diceone");
        dice_one.innerHTML = "First die: " + board.current_turn.roll_one;
        var pass = document.querySelector("#pass");
        pass.innerHTML = "pass";
        pass.onclick = function (event) {
        ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'end_turn'}));
    };

    }
    if (board.current_turn.rolled && board.current_turn.dice_count > 1){
        var dice_two = document.querySelector("#dicetwo");
        dice_two.innerHTML = "Second die: " + board.current_turn.roll_two;
    }

    if (board.current_turn.rolled && !board.current_turn.paid_out) {
        var pay_out = document.querySelector("#pay-out");
        pay_out.innerHTML = "Settle Up";
        pay_out.onclick = function (event) {
            ws.send(JSON.stringify({"game_id": getGameId(), 'message': 'run'}));
            pay_out.innerHTML = "";
        };
    }
};

ws.onmessage = function(message) {
    var board = JSON.parse(message.data);
    displayBoard(board);
};
