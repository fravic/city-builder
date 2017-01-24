port module Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Dict exposing (..)

import Game.Model as Game

port writePort : Game.PortableGame -> Cmd msg
port readPort : (Game.PortableGame -> msg) -> Sub msg

gameToPortable : Game.Game -> Game.PortableGame
gameToPortable game =
  { game |
      cities = Dict.toList game.cities
    , cityBlocks = Dict.toList game.cityBlocks
    , cityBlockTypes = Dict.toList (Dict.map cityBlockTypeToPortable game.cityBlockTypes)
  }

cityBlockTypeToPortable : String -> Game.CityBlockType -> Game.PortableCityBlockType
cityBlockTypeToPortable key cityBlockType =
  { cityBlockType | effects = (List.map cityBlockEffectToValue cityBlockType.effects) }

gameFromPortable : Game.PortableGame -> Game.Game
gameFromPortable portGame =
  { portGame |
      cities = Dict.fromList portGame.cities
    , cityBlocks = Dict.fromList portGame.cityBlocks
    , cityBlockTypes = Dict.map cityBlockTypeFromPortable (Dict.fromList portGame.cityBlockTypes)
  }

cityBlockTypeFromPortable : String -> Game.PortableCityBlockType -> Game.CityBlockType
cityBlockTypeFromPortable key portCityBlockType =
  { portCityBlockType | effects = (List.map cityBlockEffectFromValue portCityBlockType.effects)}

cityBlockEffectFromValue : (String, Int) -> Game.CityBlockEffect
cityBlockEffectFromValue (effect, value) =
  case effect of
    "PlusAction" -> Game.PlusAction value
    "PlusBuy" -> Game.PlusBuy value
    "PlusPower" -> Game.PlusPower value
    "PlusCoins" -> Game.PlusCoins value
    _ -> Game.NoEffect

cityBlockEffectToValue : Game.CityBlockEffect -> (String, Int)
cityBlockEffectToValue effect =
  case effect of
    Game.PlusAction value -> ("PlusAction", value)
    Game.PlusBuy value -> ("PlusBuy", value)
    Game.PlusPower value -> ("PlusPower", value)
    Game.PlusCoins value -> ("PlusCoins", value)
    Game.NoEffect -> ("NoEffect", 0)
