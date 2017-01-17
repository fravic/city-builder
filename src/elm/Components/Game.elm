module Components.Game exposing (gameDisplay)

import Array exposing (Array)
import Dict exposing (Dict)
import List.Extra exposing (find)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Model exposing (..)

cityBlockIdBelongsToCity : Game -> City -> String -> Bool
cityBlockIdBelongsToCity game city cityBlockId =
  case find (\id -> id == cityBlockId) city.cityBlockIds of
    Just _ -> True
    Nothing -> False

cityBlockIdBelongsToPlayer : Game -> Player -> String -> Bool
cityBlockIdBelongsToPlayer game player cityBlockId =
  let
    city = Dict.get player.cityId game.cities
  in
    case city of
      Just city -> cityBlockIdBelongsToCity game city cityBlockId
      Nothing -> False

cityBlockIdBelongsToCurrentPlayer : Game -> String -> Bool
cityBlockIdBelongsToCurrentPlayer game cityBlockId =
  let
    player = Array.get (game.turnCounter % 2) game.players
  in
    case player of
      Just player -> cityBlockIdBelongsToPlayer game player cityBlockId
      Nothing -> False

cityBlockDisplay : Game -> (String, CityBlock) -> Html Msg
cityBlockDisplay game (cityBlockId, cityBlock) =
  let
    cityBlockTypes = game.cityBlockTypes
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
    currentPlayer = cityBlockIdBelongsToCurrentPlayer game cityBlockId
    styles =
      if cityBlock.activated then [("color", "green")] else
        if currentPlayer then [("color", "black")] else [("color", "gray")]
    onClickAction =
      if currentPlayer && not cityBlock.activated then (ActivateCityBlock cityBlockId) else NoOp
  in
    case cityBlockType of
      Just cityBlockType ->
        div [style styles, onClick onClickAction] [text cityBlockType.name]
      Nothing -> div [] []

cityDisplay : City -> Html a
cityDisplay city =
  div [] [text city.name]

gameDisplay : Game -> Html Msg
gameDisplay game =
  h1
    [class "h1"]
    [
      text "Current Game Turn: ",
      span [] [text (toString game.turnCounter)]
    , ul
        []
        (List.map cityDisplay (Dict.values game.cities))
    , ul
        []
        (List.map (\cityBlock -> cityBlockDisplay game cityBlock) (Dict.toList game.cityBlocks))
    ]
