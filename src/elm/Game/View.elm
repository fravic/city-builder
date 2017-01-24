module Game.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Game.Model exposing (..)
import Game.Msg as Game
import Game.City.View as CityView
import Game.Shop.View as ShopView

view : Game -> Html Game.Msg
view game =
  div [ class "container" ][
    div [ class "row" ][
      text "Current Game Turn: ",
      span [] [text (toString game.turnCounter)]
    , ul
        []
        (List.map (\city -> CityView.view game city) (Dict.values game.cities))
    , button [ class "btn", onClick Game.CreateGame ] [ text "New Game" ]
    , button [ class "btn", onClick Game.NextTurn ] [ text "Next Turn" ]
    , Html.map Game.MsgForShop (ShopView.view game)
    ]
  ]
