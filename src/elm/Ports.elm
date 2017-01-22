port module Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Dict exposing (..)

import Model exposing (..)

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
    "PlusAction" -> PlusAction value
    "PlusBuy" -> PlusBuy value
    "PlusPower" -> PlusPower value
    "PlusCoins" -> PlusCoins value
    _ -> NoEffect

cityBlockEffectToValue : CityBlockEffect -> (String, Int)
cityBlockEffectToValue effect =
  case effect of
    PlusAction value -> ("PlusAction", value)
    PlusBuy value -> ("PlusBuy", value)
    PlusPower value -> ("PlusPower", value)
    PlusCoins value -> ("PlusCoins", value)
    NoEffect -> ("NoEffect", 0)
