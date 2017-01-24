module Game.Shop.Selectors exposing (cityBlockTypesRemaining)

import Game.Model exposing (CityBlockType, Game, Purchasable)
import Game.Selectors exposing (cityBlockType)

purchasableToMaybeTuple : Game -> Purchasable -> Maybe (CityBlockType, Int)
purchasableToMaybeTuple game purchasable =
  let
    blockType = cityBlockType game purchasable.cityBlockTypeId
  in
    case blockType of
      Just blockType -> Just (blockType, purchasable.remaining)
      Nothing -> Nothing

cityBlockTypesRemaining : Game -> List (CityBlockType, Int)
cityBlockTypesRemaining game =
  game.purchasables
    |> List.map (purchasableToMaybeTuple game)
    |> List.filterMap identity
