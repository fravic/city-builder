module Model exposing (Model, Game, PortableGame, Player, City)

import Dict exposing (Dict)

type alias Model = {
  game: Game
}

type alias Game = {
  cities: Dict String City,
  players: Dict String Player,
  turnCounter: Int
}

type alias PortableGame = {
  cities: List (String, City),
  players: List (String, Player),
  turnCounter: Int
}

type alias Player = {
  cityId: String
}

type alias City = {
  name: String
}
