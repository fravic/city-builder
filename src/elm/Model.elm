module Model exposing (..)

import Random exposing (Seed)

import Game.Model as Game

type alias Model = {
  game: Game.Game,
  randomSeed: Seed
}
