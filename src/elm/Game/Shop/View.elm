module Game.Shop.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Game.Model exposing (CityBlockType, Game, Purchasable)
import Game.Shop.Selectors exposing (cityBlockTypesRemaining)
import Game.Shop.Msg exposing (..)

import Game.Selectors exposing (
  buysRemainingForCity,
  coinsRemainingForCity,
  currentCity
  )

clickPurchasable : Bool -> CityBlockType -> Msg
clickPurchasable canPurchase cityBlockType =
  if canPurchase
    then Purchase cityBlockType
    else NoOp

stylePurchasable : Bool -> List (String, String)
stylePurchasable canPurchase =
  if canPurchase
    then [("color", "black")]
    else [("color", "gray")]

cityBlockTypeView : Int -> Int -> (CityBlockType, Int) -> Html Msg
cityBlockTypeView buysAvailable coinsAvailable (cityBlockType, remaining) =
  let
    canPurchase = buysAvailable > 0 && coinsAvailable >= cityBlockType.cost && remaining > 0
  in
    div [
      style (stylePurchasable canPurchase)
    , onClick (clickPurchasable canPurchase cityBlockType)
    ] [
      text cityBlockType.name
    , text " "
    , text (toString remaining)
    ]

view : Game -> Html Msg
view game =
  let
    cityBlockTypes = cityBlockTypesRemaining game
    (buysRemaining, coinsRemaining) = currentCity game
      |> Maybe.andThen (\city ->
          Just (buysRemainingForCity game city, coinsRemainingForCity game city))
      |> Maybe.withDefault (0, 0)
  in
    div [class "shop"] [
      h1 [] [text "Shop"]
    , ul [] (List.map (cityBlockTypeView buysRemaining coinsRemaining) cityBlockTypes)
    ]
