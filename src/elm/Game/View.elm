module Game.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Game.Types exposing (..)
import Game.City.View as CityView
import Types

view : Game -> Html Types.Msg
view game =
  div [ class "container" ][
    div [ class "row" ][
      text "Current Game Turn: ",
      span [] [text (toString game.turnCounter)]
    , ul
        []
        (List.map (\city -> CityView.view game city) (Dict.values game.cities))
    , button [ class "btn", onClick (Types.MsgForGame <| CreateGame) ] [ text "New Game" ]
    , button [ class "btn", onClick (Types.MsgForGame <| NextTurn) ] [ text "Next Turn" ]
    ]
  ]
