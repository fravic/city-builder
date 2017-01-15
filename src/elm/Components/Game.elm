module Components.Game exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

game : Int -> Html a
game currentTurn =
  h1
    [ class "h1" ]
    [
      text "Current Game Turn: ",
      span [] [ text ( toString currentTurn ) ]
    ]
