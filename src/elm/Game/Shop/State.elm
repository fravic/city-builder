module Game.Shop.State exposing (update)

import Game.Model exposing (Game)
import Game.Shop.Msg exposing (..)

update : Msg -> Game -> Game
update msg game =
  case msg of
    -- TODO: Decrement remaining purchasables and update player city blocks
    Purchase cityBlockType -> game
