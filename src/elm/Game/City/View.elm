module Game.City.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)

import Game.City.CityBlock.View as CityBlockView
import Game.Selectors exposing (
  actionsRemainingForCity,
  buysRemainingForCity,
  cityBlock,
  coinsRemainingForCity,
  currentCity
  )
import Game.Model exposing (..)
import Game.Msg as Game
import Game.City.Model exposing (..)

view : Game -> City -> Html Game.Msg
view game city =
  let
    currentPlayer = (currentCity game) == Just city
    actionsRemaining = (actionsRemainingForCity game city)
    activatable = currentPlayer && actionsRemaining > 0
    cityBlocks = city.cityBlockIds
      |> List.filterMap (\cityBlockId -> Dict.get cityBlockId game.cityBlocks)
  in
    div [style [("margin-bottom", "25px")]] [
      (text city.name),
      (div [] [
        (text "Actions:")
      , (text (actionsRemainingForCity game city |> toString))
      ])
    , (div [] [
        (text "Buys:")
      , (text (buysRemainingForCity game city |> toString))
      ])
    , (div [] [
        (text "Coins:")
      , (text (coinsRemainingForCity game city |> toString))
      ])
    , (div [] [
        (text "City Blocks")
      , (ul
          []
          (List.map (\cityBlock ->
            Html.map (Game.MsgForCityBlock cityBlock.id) (
              CityBlockView.view game activatable cityBlock
            )
          ) cityBlocks)
        )
      ])
    ]
