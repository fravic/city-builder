module Components.Game exposing (gameDisplay)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)

import Model exposing (..)

cityBlockDisplay: Dict String CityBlockType -> CityBlock -> Html a
cityBlockDisplay cityBlockTypes cityBlock =
  let
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
  in
    case cityBlockType of
      Just cityBlockType -> div [] [text cityBlockType.name]
      Nothing -> div [] []

cityDisplay : City -> Html a
cityDisplay city =
  div [] [text city.name]

gameDisplay : Game -> Html a
gameDisplay game =
  h1
    [ class "h1" ]
    [
      text "Current Game Turn: ",
      span [] [ text ( toString game.turnCounter ) ]
    , ul
        []
        ( List.map cityDisplay ( Dict.values game.cities ) )
    , ul
        []
        ( List.map (\cityBlock -> cityBlockDisplay game.cityBlockTypes cityBlock) ( Dict.values game.cityBlocks ) )
    ]
