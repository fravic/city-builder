module Update.NextTurn exposing (nextTurn)

import Dict exposing (..)
import Random exposing (..)

import Config exposing (defaultPowerCount)
import Helpers exposing (getCurrentCity, getCurrentCityBlocks, shuffleList)
import Model exposing (..)
import Ports exposing (gameToPortable, writePort)

deactivateAllCityBlocks : Game -> Game
deactivateAllCityBlocks game =
  let
    deactivateCityBlock = \(id, cityBlock) -> (id, { cityBlock |
      activated = False
    , powered = False })
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

    cityBlocks = getCurrentCityBlocks game
    (shuffledCityBlocks, nextRandSeed) = (shuffleList randSeed cityBlocks)
    poweredCityBlocks = (List.indexedMap powerUpFirstFew shuffledCityBlocks)
      |> List.map (\cityBlock -> (cityBlock.id, cityBlock))
      |> Dict.fromList
    nextGame = { game | cityBlocks = (Dict.union poweredCityBlocks game.cityBlocks) }
  in
    (nextGame, nextRandSeed)

nextTurn : Model -> (Model, Cmd Msg)
nextTurn model =
  let
    (nextGame, nextRandSeed) = model.game
        |> deactivateAllCityBlocks
        |> advanceGameTurn
        |> powerUpRandomCityBlocks model.randomSeed
  in
    ( { model | game = nextGame, randomSeed = nextRandSeed }
    , writePort (gameToPortable nextGame)
    )
