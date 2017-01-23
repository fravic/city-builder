module Game.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)

import Game.City.Types exposing (City)
import Game.City.CityBlock.Types as CityBlockTypes

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
  id: String,
  cityId: String
}

type alias CityBlock = {
  id: String,
  cityBlockTypeId: String,
  activated: Bool,
  powered: Bool
}

type CityBlockEffect = NoEffect | PlusAction Int | PlusBuy Int | PlusPower Int | PlusCoins Int

type alias CityBlockType = {
  id: String,
  name: String,
  cost: Int,
  effects: List CityBlockEffect
}

type alias PortableCityBlockType = {
  id: String,
  name: String,
  cost: Int,
  effects: List (String, Int)
}

type Msg = NoOp | CreateGame | NextTurn | ReadGame PortableGame | MsgForCityBlock String CityBlockTypes.Msg
