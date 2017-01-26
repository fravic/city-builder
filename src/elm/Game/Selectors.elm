module Game.Selectors exposing (
  actionsRemainingForCity,
  buysRemainingForCity,
  cityBlock,
  cityBlockType,
  coinsRemainingForCity,
  currentCity,
  currentCityBlocks
  )

import Array exposing (Array)
import Dict exposing (Dict)

import Config exposing (defaultActionCount, defaultBuyCount)
import Game.City.Model exposing (City)
import Game.Model as Game exposing (Game, CityBlock, CityBlockEffect, CityBlockType)

currentCity : Game -> Maybe City
currentCity game =
  Array.get (game.turnCounter % 2) game.players         -- Player
    |> Maybe.andThen (\a -> Just a.cityId)              -- Player.cityId
    |> Maybe.andThen (\key -> Dict.get key game.cities) -- City

currentCityBlocks : Game -> List (CityBlock)
currentCityBlocks game =
  Maybe.map .id (currentCity game)
    |> Maybe.andThen (\nextCityId -> Dict.get nextCityId game.cities)
    |> Maybe.andThen (\a -> Just a.cityBlockIds)
    |> Maybe.withDefault []
    |> List.filterMap (\cityBlockId -> Dict.get cityBlockId game.cityBlocks)

cityBlock : Game -> String -> Maybe CityBlock
cityBlock game cityBlockId = Dict.get cityBlockId game.cityBlocks

cityBlockType : Game -> String -> Maybe CityBlockType
cityBlockType game cityBlockTypeId = Dict.get cityBlockTypeId game.cityBlockTypes

plusActionsEffect : CityBlockEffect -> Int -> Int
plusActionsEffect effect soFar =
  case effect of
    Game.PlusAction value -> soFar + value
    _ -> soFar

plusBuysEffect : CityBlockEffect -> Int -> Int
plusBuysEffect effect soFar =
  case effect of
    Game.PlusBuy value -> soFar + value
    _ -> soFar

plusCoinsEffect : CityBlockEffect -> Int -> Int
plusCoinsEffect effect soFar =
  case effect of
    Game.PlusCoins value -> soFar + value
    _ -> soFar

activatedCityBlocks : Game -> City -> (List CityBlock)
activatedCityBlocks game city =
  List.filterMap (cityBlock game) city.cityBlockIds
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
    minusBuys = List.filterMap (cityBlock game) city.cityBlockIds
      |> List.filter .justPurchased
      |> List.length
  in
    (plusBuys - minusBuys + defaultBuyCount)

coinsRemainingForCity : Game -> City -> Int
coinsRemainingForCity game city =
  let
    plusCoins = (sumCityBlockEffects plusCoinsEffect) game city
    minusCoins = List.filterMap (cityBlock game) city.cityBlockIds
      |> List.filter .justPurchased
      |> List.map .cityBlockTypeId
      |> List.filterMap (cityBlockType game)
      |> List.map .cost
      |> List.foldr (+) 0
  in
    plusCoins - minusCoins
