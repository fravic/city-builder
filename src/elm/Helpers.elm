module Helpers exposing (getCurrentCity, getCurrentCityBlocks, shuffleList)

import Array exposing (Array)
import Dict exposing (Dict)
import Random exposing (Seed)

import Model exposing (..)

getCurrentCity : Game -> Maybe City
getCurrentCity game =
  Array.get (game.turnCounter % 2) game.players         -- Player
    |> Maybe.andThen (\a -> Just a.cityId)              -- Player.cityId
    |> Maybe.andThen (\key -> Dict.get key game.cities) -- City

getCurrentCityBlocks : Game -> List (CityBlock)
getCurrentCityBlocks game =
  Maybe.map .id (getCurrentCity game)
    |> Maybe.andThen (\nextCityId -> Dict.get nextCityId game.cities)
    |> Maybe.andThen (\a -> Just a.cityBlockIds)
    |> Maybe.withDefault []
    |> List.filterMap (\cityBlockId -> Dict.get cityBlockId game.cityBlocks)

shuffleList : Seed -> List a -> (List a, Seed)
shuffleList randSeed list =
  let
    len = (List.length list)
    rand = Random.step (Random.list len (Random.int 0 Random.maxInt)) randSeed
    -- Zip list with rand ints and then sort by the rand ints
    nextList = List.map2 (,) (Tuple.first rand) list
      |> List.sortBy Tuple.first
      |> List.unzip
      |> Tuple.second
  in
    (nextList, Tuple.second rand)
