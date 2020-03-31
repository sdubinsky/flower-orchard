if (window.document.location.hostname === "localhost") {
    var scheme = "ws://";
}else{
    var scheme = "wss://";
}
var uri = scheme + window.document.location.host + window.document.location.pathname + "/";
var ws = new WebSocket(uri);

var getGameId = function(){
    var game_id = window.document.location.pathname.split("/");
    game_id = game_id[game_id.length - 1];
    return game_id;
};

var buildPlayerElem = function(player, can_buy){
    let player_elem = document.createElement("div");
    player_elem.className += "player-div";
    let name_elem = document.createElement("div");
    name_elem.className += "player-name";
    name_elem.innerHTML = "name: " + player.name;
    player_elem.appendChild(name_elem);
    let cash_elem = document.createElement("div");
    cash_elem.className += "player-cash";
    cash_elem.innerHTML = "cash: " + player.cash;
    player_elem.appendChild(cash_elem);
    player_elem.innerHTML += "Cards:<br />"
    player.hand.forEach(function(card){
        let card_elem = document.createElement("div");
        card_elem.className += "player-card";
        card_elem.innerHTML = card.count + " " + card.name + ".  Activates on: " + card.active_numbers;
        player_elem.appendChild(card_elem);
    });
    player_elem.innerHTML += "Improvements<br />"
    player.improvements.forEach(function(improvement) {
        let imp_elem = document.createElement("div");
        imp_elem.className += "player-improvement";
        imp_elem.innerHTML = "name: " + improvement.name + ".  cost: " + improvement.cost + ".  active: " + improvement.active;
        player_elem.appendChild(imp_elem);
        if (can_buy && !improvement.active){
            buy = document.createElement("button");
            buy.className = "buy-button";
            buy.onclick = function (event) {
                ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'buy improvement ' + improvement.name}));
                
            };
            buy.innerHTML = "Activate";
            imp_elem.appendChild(buy);
        }
        player_elem.appendChild(document.createElement("br"));
    });
    return player_elem;
};

var displayBoard = function(board) {
    var players_div = document.querySelector('#players');
    players_div.innerHTML = "";
    board.players.forEach(function(player){
        let can_buy = (board.current_turn.rolls > 0) && (player.name == board.current_player.name);
        let elem = buildPlayerElem(player, can_buy);
        players_div.appendChild(elem);
    });
    var field_div = document.querySelector("#field");
    field_div.innerHTML = "";
    board.field.forEach(function(card){
        let elem = document.createElement("div");
        elem.innerHTML = card.description;
        field_div.appendChild(elem);
        if (board.current_turn.rolls > 0){
            let buyme = document.createElement("button");
            buyme.innerHTML = "Buy";
            buyme.className += "buy-button";
            elem.onclick = function (event){
                ws.send(JSON.stringify({'game_id': getGameId(), 'message': "buy card " + card.name}));
            };
            elem.appendChild(buyme);
        }
        field_div.appendChild(document.createElement("br"));
    });
    if (board.current_turn.rolls > 0){
        pass = document.createElement("button");
        pass.innerHTML = "pass";
        pass.onclick = function (event) {
            ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'end_turn'}));
        };
        field_div.appendChild(pass);
    }
    var pay_out = document.querySelector("#pay-out");
    pay_out.innerHTML = "";

    document.querySelector('#current-player').innerHTML = "current player: " + board.current_player.name;
    if (board.current_turn.rolls == 0){
        var dice_one = document.querySelector("#diceone");
        dice_one.innerHTML = "";
        var dice_two = document.querySelector("#dicetwo");
        dice_two.innerHTML = "";
    }
    if (board.current_turn.rolls == 0 || board.can_roll_again) {
        var roll_one = document.createElement("button");
        roll_one.onclick = function (event) {
            ws.send(JSON.stringify({'game_id': getGameId(), 'message': 'roll one'}));
        };
        roll_one.innerHTML = "Roll One";
        var roll_two = document.createElement("button");
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
    if (board.current_turn.rolls > 0){
        var dice_one = document.querySelector("#diceone");
        dice_one.innerHTML = "First die: " + board.current_turn.roll_one;        
    }
    if (board.current_turn.rolls > 0 && !board.can_roll_again){
        var rolldice = document.querySelector('#rolldice');
        rolldice.innerHTML = "";
    }
    if (board.current_turn.rolls > 0 && board.current_turn.dice_count > 1){
        var dice_two = document.querySelector("#dicetwo");
        dice_two.innerHTML = "Second die: " + board.current_turn.roll_two;
    }

    if (board.current_turn.rolls > 0 && !board.current_turn.paid_out) {
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
