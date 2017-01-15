var Elm = require('../elm/Main');

var app = Elm.Main.embed(document.getElementById('main'));

// Set up ports for JS interop
app.ports.write.subscribe(function (game) {
  console.log("Write game", game);
  setTimeout(function() {
    app.ports.read.send({ turnCounter: game.turnCounter + 5 });
    console.log('Sent back');
  }, 1000);
});
