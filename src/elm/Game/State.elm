module Game.State exposing (initial, subscriptions, update)

import Array exposing (Array)
import Dict exposing (..)
import Random exposing (..)

import Config exposing (defaultPowerCount)
import Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)
import Game.City.CityBlock.State as CityBlockState
import Game.Selectors exposing (cityBlock, currentCity)
import Game.Model exposing (..)
import Game.Msg exposing (..)
import Game.Shop.State as ShopState

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
          , actionCost = 1
          })
      , ("cbt1",
          { id = "cbt1"
          , name = "Bank"
          , cost = 1
          , effects = [
              PlusBuy 1
            , PlusCoins 2
            ]
          , actionCost = 1
          })
      , ("cbt2",
          { id = "cbt2"
          , name = "Startup"
          , cost = 1
          , effects = [
              PlusCoins 2
            ]
          , actionCost = 0
          })
      , ("cbt3",
          { id = "cbt3"
          , name = "House"
          , cost = 1
          , effects = [
              EndgameVictoryPoints 1
            ]
          , actionCost = 0
          })
      ]
  , purchasables = [
      { remaining = 10, cityBlockTypeId = "cbt0" }
    , { remaining = 10, cityBlockTypeId = "cbt1" }
    , { remaining = 10, cityBlockTypeId = "cbt2" }
    , { remaining = 10, cityBlockTypeId = "cbt3" }
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

nextTurn : Seed -> Game -> (Game, Seed)
nextTurn randomSeed game =
  let
    (nextGame, nextRandSeed) = game
        |> deactivateAllCityBlocks
        |> advanceGameTurn
        |> CityBlockState.powerUpRandomCityBlocks randomSeed defaultPowerCount
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
      cityBlock game cityBlockId
        |> Maybe.andThen (CityBlockState.update msg seed game >> Just)
        |> Maybe.withDefault (game, seed)
    MsgForShop msg ->
      (ShopState.update msg game, seed)

-- SUBSCRIPTIONS
subscriptions : Game -> Sub Msg
subscriptions game =
  readPort ReadGame
