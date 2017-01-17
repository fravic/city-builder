module Components.Game exposing (gameDisplay)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Model exposing (..)

cityBlockDisplay: Dict String CityBlockType -> (String, CityBlock) -> Html Msg
cityBlockDisplay cityBlockTypes (cityBlockId, cityBlock) =
  let
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
    styles = if cityBlock.activated then [("color", "green")] else [("color", "black")]
  in
    case cityBlockType of
      Just cityBlockType ->
        div [style styles, onClick (ActivateCityBlock cityBlockId)] [text cityBlockType.name]
      Nothing -> div [] []

cityDisplay : City -> Html a
cityDisplay city =
  div [] [text city.name]

gameDisplay : Game -> Html Msg
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
        ( List.map (\cityBlock -> cityBlockDisplay game.cityBlockTypes cityBlock) ( Dict.toList game.cityBlocks ) )
    ]
