port module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Model exposing (..)
import Components.Game exposing ( gameDisplay )


-- APP
main : Program Never Model Msg
main =
  Html.program
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
      [ { cityId = "c0" }
      , { cityId = "c1" }
      ]
  , cities = Dict.fromList
      [ ("c0", { name = "San Francisco", cityBlockIds = [ "cb0" ] })
      , ("c1", { name = "Toronto", cityBlockIds = [ "cb1" ] })
      ]
  , cityBlocks = Dict.fromList
      [ ("cb0", { cityBlockTypeId = "cbt0", activated = False })
      , ("cb1", { cityBlockTypeId = "cbt1", activated = False })
      ]
  , cityBlockTypes = Dict.fromList
      [ ("cbt0",
          { name = "Restaurant"
          , cost = 3
          , effects = [
              PlusPower 1
            , PlusAction 2
            ]
          })
      , ("cbt1",
          { name = "Bank"
          , cost = 3
          , effects = [
              PlusBuy 1
            , PlusCoins 2
            ]
          })
      ]
  , turnCounter = 0
  }

init : (Model, Cmd Msg)
init =
  ( Model initialGame,
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
        nextGame =
          { prevGame |
            turnCounter = prevGame.turnCounter + 1
          , cityBlocks = Dict.toList prevGame.cityBlocks |> deactivateAllCityBlocks |> Dict.fromList
          }
      in
        ( { model | game = nextGame }
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
    (id, { cityBlock | activated = False })
  ) cityBlocks

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
