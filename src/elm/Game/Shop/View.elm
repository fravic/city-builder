module Game.Shop.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Game.Model exposing (CityBlockType, Game, Purchasable)
import Game.Shop.Selectors exposing (cityBlockTypesRemaining)
import Game.Shop.Msg exposing (..)

cityBlockTypeView : (CityBlockType, Int) -> Html Msg
cityBlockTypeView (cityBlockType, remaining) =
  div [class "purchasable", onClick (Purchase cityBlockType)] [
    text cityBlockType.name,
    text (toString remaining)
  ]

view : Game -> Html Msg
view game =
  let
    cityBlockTypes = cityBlockTypesRemaining game
  in
    div [class "shop"] [
      h1 [] [text "Shop"]
    , ul [] (List.map cityBlockTypeView cityBlockTypes)
    ]
