module Types exposing (..)

import Random exposing (Seed)

import Game.Types exposing (Game, PortableGame)

type alias Model = {
  game: Game,
  randomSeed: Seed
}

type Msg = NoOp | MsgForGame Game.Types.Msg
