module Components.Game exposing (gameDisplay)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)

import Model exposing (..)

cityDisplay : City -> Html a
cityDisplay city =
  div [] [text city.name]

gameDisplay : Game -> Html a
gameDisplay game =
  h1
    [ class "h1" ]
    [
      text "Current Game Turn: ",
      span [] [ text ( toString game.turnCounter ) ],
      ul
        []
        ( List.map cityDisplay (Dict.values game.cities) )
    ]
