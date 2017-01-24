module Game.City.CityBlock.State exposing (update)

import Game.City.CityBlock.Msg exposing (..)
import Game.Model exposing (CityBlock)

update : Msg -> CityBlock -> CityBlock
update msg cityBlock =
  case msg of
    NoOp -> cityBlock
    Activate -> { cityBlock | activated = True }