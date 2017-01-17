module Components.Game exposing (gameDisplay)

import Array exposing (Array)
import Dict exposing (Dict)
import List.Extra exposing (find)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Model exposing (..)

cityBlockIdBelongsToCurrentPlayer : Game -> String -> Bool
cityBlockIdBelongsToCurrentPlayer game cityBlockId =
  let
    foundCityBlock = Array.get (game.turnCounter % 2) game.players -- Player
      |> Maybe.andThen (\a -> Just a.cityId)                       -- Player.cityId
      |> Maybe.andThen (\key -> Dict.get key game.cities)          -- City
      |> Maybe.andThen (\a -> Just a.cityBlockIds)                 -- City.cityBlockIds
      |> Maybe.andThen (find (\id -> id == cityBlockId))           -- String
  in
    case foundCityBlock of
      Just _ -> True
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
