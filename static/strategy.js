var stompClient = null;

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    if (connected) {
        $("#conversation").show();
    }
    else {
        $("#conversation").hide();
    }
    $("#console").html("");
}

function connect() {
    var socket = new SockJS('/strategy_fetch');
    stompClient = Stomp.over(socket);
    stompClient.connect({}, function (frame) {
        setConnected(true);
        console.log('Connected: ' + frame);
        stompClient.subscribe('/wsTopic/strategy', function (console) {
            showGreeting(JSON.parse(console.body).parameter);
        });
    });
    showGreeting("Server conneced.");
}

function disconnect() {
    if (stompClient !== null) {
        stompClient.disconnect();
    }
    setConnected(false);
    console.log("Disconnected");
}

function shutdown() {
    stompClient.send("/mdcon/command", {}, JSON.stringify({'order': 'shutdown'}));
}
function submitcommand(paras) {
    showGreeting(paras);
    $("#command").val('');
    stompClient.send("/mdcon/command", {}, JSON.stringify({'order': 'command', 'parameters':paras}));
}
function clear() {
    $("#console").empty();
}

function showGreeting(message) {
    $("#console").append( message + "<br>");
}

$(function () {
    $("#fileload").click(function() { return;});

    $("#wsform").on('submit', function (e) {
        e.preventDefault();
    });


    $( "#connect" ).click(function() { connect(); });
    $( "#disconnect" ).click(function() { disconnect(); });

    $( "#clear" ).click(function() { clear(); });
    $( "#command" ).change(function() {
        var comsend = $( "#command" ).val();
        submitcommand(comsend);
    });


});