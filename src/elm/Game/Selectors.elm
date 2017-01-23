module Game.Selectors exposing (
  currentCity,
  currentCityBlocks,
  cityBlock,
  actionsRemainingForCity,
  buysRemainingForCity,
  coinsRemainingForCity
  )

import Array exposing (Array)
import Dict exposing (Dict)

import Config exposing (defaultActionCount, defaultBuyCount)
import Game.City.Types exposing (City)
import Game.Types exposing (Game, CityBlock, CityBlockEffect)

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

plusActionsEffect : CityBlockEffect -> Int -> Int
plusActionsEffect effect soFar =
  case effect of
    Game.Types.PlusAction value -> soFar + value
    _ -> soFar

plusBuysEffect : CityBlockEffect -> Int -> Int
plusBuysEffect effect soFar =
  case effect of
    Game.Types.PlusBuy value -> soFar + value
    _ -> soFar

plusCoinsEffect : CityBlockEffect -> Int -> Int
plusCoinsEffect effect soFar =
  case effect of
    Game.Types.PlusCoins value -> soFar + value
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
  in
    (plusBuys + defaultBuyCount) -- TODO: Factor in how many buys the player has performed this turn

coinsRemainingForCity : Game -> City -> Int
coinsRemainingForCity = sumCityBlockEffects plusCoinsEffect
