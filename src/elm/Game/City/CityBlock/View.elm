module Game.City.CityBlock.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Game.Model as GameTypes exposing (Game, CityBlock)
import Game.City.CityBlock.Msg exposing (..)

view : Game -> Bool -> Int -> CityBlock -> Html Msg
view game currentPlayer actionsRemaining cityBlock =
  let
    cityBlockTypes = game.cityBlockTypes
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
    enoughActions = Maybe.map (\a -> actionsRemaining >= a.actionCost) cityBlockType
      |> Maybe.withDefault False
    activatable = currentPlayer && enoughActions
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
