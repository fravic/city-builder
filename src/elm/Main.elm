port module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )
import Random exposing (..)

import Model exposing (..)
import Components.Game exposing ( gameDisplay )


-- APP
main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }


-- MODEL
initialGame : Game
initialGame =
  {
    players = Array.fromList
      [ { id = "p0", cityId = "c0" }
      , { id = "p1", cityId = "c1" }
      ]
  , cities = Dict.fromList
      [ ("c0", { id = "c0", name = "San Francisco", cityBlockIds = [ "cb0", "cb2" ] })
      , ("c1", { id = "c1", name = "Toronto", cityBlockIds = [ "cb1" ] })
      ]
  , cityBlocks = Dict.fromList
      [ ("cb0", { id = "cb0", cityBlockTypeId = "cbt0", activated = False, powered = False })
      , ("cb1", { id = "cb1", cityBlockTypeId = "cbt1", activated = False, powered = False })
      , ("cb2", { id = "cb2", cityBlockTypeId = "cbt1", activated = False, powered = False })
      ]
  , cityBlockTypes = Dict.fromList
      [ ("cbt0",
          { id = "cbt0"
          , name = "Restaurant"
          , cost = 3
          , effects = [
              PlusPower 1
            , PlusAction 2
            ]
          })
      , ("cbt1",
          { id = "cbt1"
          , name = "Bank"
          , cost = 3
          , effects = [
              PlusBuy 1
            , PlusCoins 2
            ]
          })
      ]
  , turnCounter = 0
  }

type alias Flags = { startTime: Int }

init : Flags -> (Model, Cmd Msg)
init flags =
  ( Model initialGame (Random.initialSeed flags.startTime),
    Cmd.none
  )


-- PORTS
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


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  readPort ReadGame


-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    CreateGame ->
      let
        nextGame = initialGame
      in ( { model | game = initialGame }
         , writePort (gameToPortable nextGame)
         )
    NextTurn ->
      let
        prevGame = model.game
        (nextCityBlocks, nextRandSeed) = Dict.toList prevGame.cityBlocks
            |> deactivateAllCityBlocks
            |> powerUpRandomCityBlocks prevGame model.randomSeed
        nextGame =
          { prevGame |
            turnCounter = prevGame.turnCounter + 1
          , cityBlocks = nextCityBlocks |> Dict.fromList
          }
      in
        ( { model | game = nextGame, randomSeed = nextRandSeed }
        , writePort (gameToPortable nextGame)
        )
    ReadGame portGame ->
      let
        nextGame = gameFromPortable portGame
      in
        ({ model | game = nextGame }, Cmd.none)
    ActivateCityBlock cityBlockId ->
      let
        prevGame = model.game
        nextGame = { prevGame | cityBlocks = Dict.update cityBlockId activateCityBlock prevGame.cityBlocks }
      in
        ({ model | game = nextGame }, writePort (gameToPortable nextGame))

activateCityBlock : Maybe CityBlock -> Maybe CityBlock
activateCityBlock maybeCityBlock =
  case maybeCityBlock of
    Just cityBlock -> Just { cityBlock | activated = True }
    Nothing -> maybeCityBlock

deactivateAllCityBlocks : List (String, CityBlock) -> List (String, CityBlock)
deactivateAllCityBlocks cityBlocks =
  List.map (\(id, cityBlock) ->
    (id, { cityBlock | activated = False, powered = False })
  ) cityBlocks

-- TODO: Only power up city blocks of current player
powerUpRandomCityBlocks : Game -> Seed -> List (String, CityBlock) -> (List (String, CityBlock), Seed)
powerUpRandomCityBlocks game randSeed cityBlocks =
  let
    len = (List.length cityBlocks)
    rand = Random.step (Random.list len (Random.int 0 Random.maxInt)) randSeed
    randCityBlocks = List.map2 (,) (Tuple.first rand) cityBlocks -- Zip city blocks with rand ints
      |> List.sortBy Tuple.first                                 -- Sort by rand ints
      |> List.unzip
      |> Tuple.second
    powerUp = \idx (id, cityBlock) ->
      if idx < 1
        then (id, { cityBlock | powered = True })
        else (id, cityBlock)
  in
    ((List.indexedMap powerUp randCityBlocks), (Tuple.second rand))


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container" ][
    div [ class "row" ][
      gameDisplay model.game
    , button [ class "btn", onClick CreateGame ] [ text "New Game" ]
    , button [ class "btn", onClick NextTurn ] [ text "Next Turn" ]
    ]
  ]
