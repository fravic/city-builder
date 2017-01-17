module Model exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)

type alias Model = {
  game: Game
}

type alias Game = {
  cities: Dict String City,
  cityBlocks: Dict String CityBlock,
  cityBlockTypes: Dict String CityBlockType,
  players: Array Player,
  turnCounter: Int
}

type alias PortableGame = {
  cities: List (String, City),
  cityBlocks: List (String, CityBlock),
  cityBlockTypes: List (String, PortableCityBlockType),
  players: Array Player,
  turnCounter: Int
}

type alias Player = {
  cityId: String
}

type alias City = {
  name: String,
  cityBlockIds: List String
}

type alias CityBlock = {
  cityBlockTypeId: String,
  activated: Bool
}

type alias CityBlockType = {
  name: String,
  cost: Int,
  effects: List CityBlockEffect
}

type alias PortableCityBlockType = {
  name: String,
  cost: Int,
  effects: List (String, Int)
}

type CityBlockEffect = NoEffect | PlusAction Int | PlusBuy Int | PlusPower Int | PlusCoins Int

type Msg = NoOp | CreateGame | NextTurn | ReadGame PortableGame | ActivateCityBlock String
