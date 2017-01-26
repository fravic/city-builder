module Game.Shop.State exposing (update)

import Dict

import Game.Model exposing (CityBlockType, Game)
import Game.Selectors
import Game.Shop.Msg exposing (..)

giveCurrentPlayerCityBlockType : CityBlockType -> Game -> Game
giveCurrentPlayerCityBlockType cityBlockType game =
  let
    currentCity = Game.Selectors.currentCity game
    newCityBlock = {
      id = Dict.size game.cityBlocks |> toString
    , cityBlockTypeId = cityBlockType.id
    , activated = False
    , powered = False
    , justPurchased = True
    }
    nextCities =
      case currentCity of
        Just currentCity -> Dict.insert currentCity.id
          { currentCity | cityBlockIds = newCityBlock.id :: currentCity.cityBlockIds }
          game.cities
        Nothing -> game.cities
    nextCityBlocks = Dict.insert newCityBlock.id newCityBlock game.cityBlocks
  in
    { game | cityBlocks = nextCityBlocks, cities = nextCities}

decrementPurchasablesRemaining : CityBlockType -> Game -> Game
decrementPurchasablesRemaining cityBlockType game =
  let
    nextPurchasables = List.map (\purchasable ->
        if purchasable.cityBlockTypeId == cityBlockType.id
        then { purchasable | remaining = purchasable.remaining - 1 }
        else purchasable
      ) game.purchasables
  in
    { game | purchasables = nextPurchasables }

update : Msg -> Game -> Game
update msg game =
  case msg of
    Purchase cityBlockType ->
      giveCurrentPlayerCityBlockType cityBlockType game
      |> decrementPurchasablesRemaining cityBlockType
    NoOp -> game
