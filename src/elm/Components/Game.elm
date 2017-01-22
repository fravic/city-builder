module Components.Game exposing (gameDisplay)

import Dict exposing (Dict)
import List.Extra exposing (find)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Config exposing (defaultActionCount, defaultBuyCount)
import Model exposing (..)
import Helpers exposing (getCurrentCity)

getCityBlock : Game -> String -> Maybe CityBlock
getCityBlock game cityBlockId = Dict.get cityBlockId game.cityBlocks

cityBlockBelongsToCurrentPlayer : Game -> CityBlock -> Bool
cityBlockBelongsToCurrentPlayer game cityBlock =
  let
    foundCityBlock = getCurrentCity game
      |> Maybe.andThen (\a -> Just a.cityBlockIds)                 -- City.cityBlockIds
      |> Maybe.andThen (find (\id -> id == cityBlock.id))          -- String
  in
    case foundCityBlock of
      Just _ -> True
      Nothing -> False

cityBlockDisplay : Game -> City -> CityBlock -> Html Msg
cityBlockDisplay game city cityBlock =
  let
    cityBlockTypes = game.cityBlockTypes
    cityBlockType = Dict.get cityBlock.cityBlockTypeId cityBlockTypes
    currentPlayer = cityBlockBelongsToCurrentPlayer game cityBlock
    actionsRemaining = (actionsRemainingForCity game city)
    styles =
      if cityBlock.activated then [("color", "green")] else
        if currentPlayer && actionsRemaining > 0 && cityBlock.powered then [("color", "black")] else [("color", "gray")]
    onClickAction =
      if currentPlayer && not cityBlock.activated && actionsRemaining > 0
        then (ActivateCityBlock cityBlock.id)
        else NoOp
  in
    case cityBlockType of
      Just cityBlockType ->
        div [style styles, onClick onClickAction] [text cityBlockType.name]
      Nothing -> div [] []

plusActionsEffect : CityBlockEffect -> Int -> Int
plusActionsEffect effect soFar =
  case effect of
    PlusAction value -> soFar + value
    _ -> soFar

plusBuysEffect : CityBlockEffect -> Int -> Int
plusBuysEffect effect soFar =
  case effect of
    PlusBuy value -> soFar + value
    _ -> soFar

plusCoinsEffect : CityBlockEffect -> Int -> Int
plusCoinsEffect effect soFar =
  case effect of
    PlusCoins value -> soFar + value
    _ -> soFar

activatedCityBlocks : Game -> City -> (List CityBlock)
activatedCityBlocks game city =
  List.filterMap (getCityBlock game) city.cityBlockIds
    |> List.filter .activated

sumCityBlockEffects : (CityBlockEffect -> Int -> Int) -> Game -> City -> Int
sumCityBlockEffects sumFunc game city =
  let
    getCityBlockType = \cityBlockTypeId -> (Dict.get cityBlockTypeId game.cityBlockTypes)
    activatedCityBlockEffects = (activatedCityBlocks game city)
      |> List.filterMap (.cityBlockTypeId >> getCityBlockType)
      |> List.concatMap .effects
  in
    List.foldr sumFunc 0 activatedCityBlockEffects

actionsRemainingForCity : Game -> City -> Int
actionsRemainingForCity game city =
  let
    plusActions = (sumCityBlockEffects plusActionsEffect) game city
    activatedCityBlocksCount = List.length (activatedCityBlocks game city)
  in
    (plusActions + defaultActionCount) - activatedCityBlocksCount

buysRemainingForCity : Game -> City -> Int
buysRemainingForCity game city =
  let
    plusBuys = (sumCityBlockEffects plusBuysEffect) game city
  in
    (plusBuys + defaultBuyCount) -- TODO: Factor in how many buys the player has performed this turn

cityDisplay : Game -> City -> Html Msg
cityDisplay game city =
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
    , (text ((sumCityBlockEffects plusCoinsEffect) game city |> toString))
    ])
  , (div [] [
      (text "City Blocks")
    , (ul
        []
        (List.map
          (cityBlockDisplay game city)
          (List.filterMap (getCityBlock game) city.cityBlockIds)
        )
      )
    ])
  ]

gameDisplay : Game -> Html Msg
gameDisplay game =
  div
    [class "game"]
    [
      text "Current Game Turn: ",
      span [] [text (toString game.turnCounter)]
    , ul
        []
        (List.map (\city -> cityDisplay game city) (Dict.values game.cities))
    ]
