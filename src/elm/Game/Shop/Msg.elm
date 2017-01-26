module Game.Shop.Msg exposing (..)

import Game.Model exposing (CityBlockType)

type Msg = NoOp
  | Purchase CityBlockType
