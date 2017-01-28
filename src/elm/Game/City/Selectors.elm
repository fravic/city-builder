module Game.City.Selectors exposing (endgameVictoryPointsForCity)

import Game.Model exposing (Game, CityBlockEffect, CityBlockType)
import Game.City.Model exposing (City)
import Game.Selectors exposing (cityBlock, cityBlockType)

endgameVictoryPointsForCityBlockEffect : CityBlockEffect -> Int
endgameVictoryPointsForCityBlockEffect effect =
  case effect of
    Game.Model.EndgameVictoryPoints value -> value
    _ -> 0

endgameVictoryPointsForCityBlockType : CityBlockType -> Int
endgameVictoryPointsForCityBlockType cityBlock =
  List.map endgameVictoryPointsForCityBlockEffect cityBlock.effects
  |> List.foldr (+) 0

endgameVictoryPointsForCity : Game -> City -> Int
endgameVictoryPointsForCity game city =
  List.filterMap (cityBlock game) city.cityBlockIds
    |> List.filterMap (.cityBlockTypeId >> cityBlockType game)
    |> List.map endgameVictoryPointsForCityBlockType
    |> List.foldr (+) 0
