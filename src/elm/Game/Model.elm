module Game.Model exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)

import Game.City.Model exposing (City)

type alias Game = {
  cities: Dict String City,
  cityBlocks: Dict String CityBlock,
  cityBlockTypes: Dict String CityBlockType,
  players: Array Player,
  purchasables: List Purchasable,
  turnCounter: Int
}

type alias PortableGame = {
  cities: List (String, City),
  cityBlocks: List (String, CityBlock),
  cityBlockTypes: List (String, PortableCityBlockType),
  players: Array Player,
  purchasables: List Purchasable,
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
  powered: Bool,
  justPurchased: Bool
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

type alias Purchasable = {
  remaining: Int,
  cityBlockTypeId: String
}
