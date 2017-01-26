module Game.State exposing (initial, subscriptions, update)

import Array exposing (Array)
import Dict exposing (..)
import Random exposing (..)

import Config exposing (defaultPowerCount)
import Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)
import Game.City.CityBlock.State as CityBlockState
import Game.Selectors exposing (currentCity, currentCityBlocks)
import Game.Model exposing (..)
import Game.Msg exposing (..)
import Game.Shop.State as ShopState
import Utils exposing (shuffleList)

-- INITIAL
initial : Game
initial =
  {
    players = Array.fromList
      [ { id = "p0", cityId = "c0" }
      , { id = "p1", cityId = "c1" }
      ]
  , cities = Dict.fromList
      [ ("c0", { id = "c0", name = "San Francisco", cityBlockIds = [ "cb0", "cb2" ] })
      , ("c1", { id = "c1", name = "Toronto", cityBlockIds = [ "cb1" ] })
      ]
  , cityBlocks = Dict.fromList
      [ ("cb0", { id = "cb0", cityBlockTypeId = "cbt0", activated = False, powered = False, justPurchased = False })
      , ("cb1", { id = "cb1", cityBlockTypeId = "cbt1", activated = False, powered = False, justPurchased = False })
      , ("cb2", { id = "cb2", cityBlockTypeId = "cbt1", activated = False, powered = False, justPurchased = False })
      ]
  , cityBlockTypes = Dict.fromList
      [ ("cbt0",
          { id = "cbt0"
          , name = "Restaurant"
          , cost = 1
          , effects = [
              PlusPower 1
            , PlusAction 2
            ]
          })
      , ("cbt1",
          { id = "cbt1"
          , name = "Bank"
          , cost = 1
          , effects = [
              PlusBuy 1
            , PlusCoins 2
            ]
          })
      ]
  , purchasables = [
      { remaining = 10, cityBlockTypeId = "cbt0" }
    , { remaining = 10, cityBlockTypeId = "cbt1" }
    ]
  , turnCounter = 0
  }

-- UPDATE
deactivateAllCityBlocks : Game -> Game
deactivateAllCityBlocks game =
  let
    deactivateCityBlock = \(id, cityBlock) -> (id, { cityBlock |
      activated = False
    , powered = False
    , justPurchased = False })
    nextCityBlocks = Dict.toList game.cityBlocks
      |> List.map deactivateCityBlock
      |> Dict.fromList
  in
    { game | cityBlocks = nextCityBlocks }

advanceGameTurn : Game -> Game
advanceGameTurn game = { game | turnCounter = game.turnCounter + 1 }

-- TODO: Only power up unpowered city blocks
powerUpRandomCityBlocks : Seed -> Game -> (Game, Seed)
powerUpRandomCityBlocks randSeed game =
  let
    powerUpFirstFew = \idx cityBlock ->
      if idx < defaultPowerCount
        then { cityBlock | powered = True }
        else cityBlock

    cityBlocks = currentCityBlocks game
    (shuffledCityBlocks, nextRandSeed) = (shuffleList randSeed cityBlocks)
    poweredCityBlocks = (List.indexedMap powerUpFirstFew shuffledCityBlocks)
      |> List.map (\cityBlock -> (cityBlock.id, cityBlock))
      |> Dict.fromList
    nextGame = { game | cityBlocks = (Dict.union poweredCityBlocks game.cityBlocks) }
  in
    (nextGame, nextRandSeed)

nextTurn : Seed -> Game -> (Game, Seed)
nextTurn randomSeed game =
  let
    (nextGame, nextRandSeed) = game
        |> deactivateAllCityBlocks
        |> advanceGameTurn
        |> powerUpRandomCityBlocks randomSeed
  in
    (nextGame, nextRandSeed)

update : Msg -> Seed -> Game -> (Game, Seed)
update msg seed game =
  case msg of
    NoOp -> (game, seed)
    CreateGame ->
      (initial, seed)
    NextTurn ->
      nextTurn seed game
    ReadGame portGame ->
      (gameFromPortable portGame, seed)
    MsgForCityBlock cityBlockId msg ->
      let
        setCityBlock = \nextCityBlock -> Just { game | cityBlocks = Dict.union (Dict.singleton cityBlockId nextCityBlock) game.cityBlocks }
        nextGame = Dict.get cityBlockId game.cityBlocks
          |> Maybe.andThen (\cityBlock -> Just (CityBlockState.update msg cityBlock))
          |> Maybe.andThen setCityBlock
          |> Maybe.withDefault game
      in
        (nextGame, seed)
    MsgForShop msg ->
      (ShopState.update msg game, seed)

-- SUBSCRIPTIONS
subscriptions : Game -> Sub Msg
subscriptions game =
  readPort ReadGame
