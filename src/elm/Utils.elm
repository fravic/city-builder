module Utils exposing (shuffleList)

import Random exposing (Seed)

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
