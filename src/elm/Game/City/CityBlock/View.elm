module Game.City.CityBlock.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Game.Types as GameTypes exposing (Game, CityBlock)
import Game.City.CityBlock.Types exposing (..)

view : Game -> Bool -> CityBlock -> Html Msg
view game activatable cityBlock =
  let
    cityBlockTypes = game.cityBlockTypes
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
    styles =
      if cityBlock.activated then [("color", "green")] else
        if activatable && cityBlock.powered then [("color", "black")] else [("color", "gray")]
    onClickAction =
      if activatable && not cityBlock.activated
        then Activate
        else NoOp
  in
    case cityBlockType of
      Just cityBlockType ->
        div [style styles, onClick onClickAction] [text cityBlockType.name]
      Nothing -> div [] []
