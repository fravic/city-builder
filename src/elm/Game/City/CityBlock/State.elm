module Game.City.CityBlock.State exposing (update, powerUpRandomCityBlocks)

import Dict
import Game.City.CityBlock.Msg exposing (..)
import Game.Model exposing (Game, CityBlock, CityBlockEffect)
import Game.Selectors exposing (cityBlockType, currentCityBlocks)
import Random exposing (..)
import Utils exposing (shuffleList)

powerUpRandomCityBlocks : Seed -> Int -> Game -> (Game, Seed)
powerUpRandomCityBlocks randSeed powerCount game =
  let
    powerUpFirstFew = \idx cityBlock ->
      if idx < powerCount
        then { cityBlock | powered = True }
        else cityBlock

    cityBlocks = currentCityBlocks game
      |> List.filter (not << .powered)
    (shuffledCityBlocks, nextRandSeed) = (shuffleList randSeed cityBlocks)
    poweredCityBlocks = (List.indexedMap powerUpFirstFew shuffledCityBlocks)
      |> List.map (\cityBlock -> (cityBlock.id, cityBlock))
      |> Dict.fromList
    nextGame = { game | cityBlocks = (Dict.union poweredCityBlocks game.cityBlocks) }
  in
    (nextGame, nextRandSeed)

setCityBlockInGame : CityBlock -> (Game, Seed) -> (Game, Seed)
setCityBlockInGame cityBlock (game, seed) =
  let
    nextGame = { game | cityBlocks = Dict.union (Dict.singleton cityBlock.id cityBlock) game.cityBlocks }
  in
    (nextGame, seed)

activateCityBlockEffect : CityBlock -> CityBlockEffect -> (Game, Seed) -> (Game, Seed)
activateCityBlockEffect cityBlock effect (game, seed) =
  case effect of
    Game.Model.PlusPower value -> powerUpRandomCityBlocks seed value game
    _ -> (game, seed)

activateCityBlock : Game -> Seed -> CityBlock -> (Game, Seed)
activateCityBlock game seed cityBlock =
  let
    cityBlockEffects = cityBlockType game cityBlock.cityBlockTypeId
      |> Maybe.map .effects
      |> Maybe.withDefault []
  in
    List.foldr (activateCityBlockEffect cityBlock) (game, seed) cityBlockEffects
      |> setCityBlockInGame { cityBlock | activated = True }

update : Msg -> Seed -> Game -> CityBlock -> (Game, Seed)
update msg seed game cityBlock =
  case msg of
    NoOp -> (game, seed)
    Activate -> activateCityBlock game seed cityBlock
