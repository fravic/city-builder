var firebase = require("firebase");

var Elm = require('../elm/Main');

var app = Elm.Main.embed(document.getElementById('main'));

const TEST_GAME_ID = 'testGame01';

// Set up ports for JS interop
app.ports.writePort.subscribe(function(game) {
  console.log("Writing game to Firebase", game);
  writeGame(game);
});

// Initialize Firebase
var config = {
  apiKey: "AIzaSyDCvlVo7yMyrcYu_qzvuFgSSmu2eM8naIk",
  authDomain: "station-dev.firebaseapp.com",
  databaseURL: "https://station-dev.firebaseio.com",
  storageBucket: "station-dev.appspot.com",
  messagingSenderId: "713714399707"
};
firebase.initializeApp(config);

function writeGame(game) {
  firebase.database().ref(TEST_GAME_ID).set(game);
}

var gameRef = firebase.database().ref(TEST_GAME_ID);
gameRef.on('value', function(gameObj) {
  console.log("Reading game from Firebase", gameObj.val());
  app.ports.readPort.send(gameObj.val());
});
