module Game.Msg exposing (..)

import Game.Model exposing (PortableGame)
import Game.City.CityBlock.Msg as CityBlock
import Game.Shop.Msg as Shop

type Msg =
    NoOp
  | CreateGame
  | NextTurn
  | ReadGame PortableGame
  | MsgForCityBlock String CityBlock.Msg
  | MsgForShop Shop.Msg
