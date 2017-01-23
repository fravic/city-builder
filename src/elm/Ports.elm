port module Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Dict exposing (..)

import Game.Types exposing (Game, PortableGame, CityBlockType, PortableCityBlockType, CityBlockEffect)

port writePort : PortableGame -> Cmd msg
port readPort : (PortableGame -> msg) -> Sub msg

gameToPortable : Game -> PortableGame
gameToPortable game =
  { game |
      cities = Dict.toList game.cities
    , cityBlocks = Dict.toList game.cityBlocks
    , cityBlockTypes = Dict.toList (Dict.map cityBlockTypeToPortable game.cityBlockTypes)
  }

cityBlockTypeToPortable : String -> CityBlockType -> PortableCityBlockType
cityBlockTypeToPortable key cityBlockType =
  { cityBlockType | effects = (List.map cityBlockEffectToValue cityBlockType.effects) }

gameFromPortable : PortableGame -> Game
gameFromPortable portGame =
  { portGame |
      cities = Dict.fromList portGame.cities
    , cityBlocks = Dict.fromList portGame.cityBlocks
    , cityBlockTypes = Dict.map cityBlockTypeFromPortable (Dict.fromList portGame.cityBlockTypes)
  }

cityBlockTypeFromPortable : String -> PortableCityBlockType -> CityBlockType
cityBlockTypeFromPortable key portCityBlockType =
  { portCityBlockType | effects = (List.map cityBlockEffectFromValue portCityBlockType.effects)}

cityBlockEffectFromValue : (String, Int) -> CityBlockEffect
cityBlockEffectFromValue (effect, value) =
  case effect of
    "PlusAction" -> Game.Types.PlusAction value
    "PlusBuy" -> Game.Types.PlusBuy value
    "PlusPower" -> Game.Types.PlusPower value
    "PlusCoins" -> Game.Types.PlusCoins value
    _ -> Game.Types.NoEffect

cityBlockEffectToValue : CityBlockEffect -> (String, Int)
cityBlockEffectToValue effect =
  case effect of
    Game.Types.PlusAction value -> ("PlusAction", value)
    Game.Types.PlusBuy value -> ("PlusBuy", value)
    Game.Types.PlusPower value -> ("PlusPower", value)
    Game.Types.PlusCoins value -> ("PlusCoins", value)
    Game.Types.NoEffect -> ("NoEffect", 0)
