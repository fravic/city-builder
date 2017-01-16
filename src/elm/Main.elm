port module Main exposing (..)

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
    players = Dict.fromList
      [ ("p0", { cityId = "c0" })
      , ("p1", { cityId = "c1" })
      ]
  , cities = Dict.fromList
      [ ("c0", { name = "San Francisco" })
      , ("c1", { name = "Toronto" })
      ]
  , cityBlocks = Dict.fromList
      [ ("cb0", { cityBlockTypeId = "cbt0" })
      , ("cb1", { cityBlockTypeId = "cbt1" })
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
      players = Dict.toList game.players
    , cities = Dict.toList game.cities
    , cityBlocks = Dict.toList game.cityBlocks
    , cityBlockTypes = Dict.toList (Dict.map cityBlockTypeToPortable game.cityBlockTypes)
  }

cityBlockTypeToPortable : String -> CityBlockType -> PortableCityBlockType
cityBlockTypeToPortable key cityBlockType =
  { cityBlockType | effects = (List.map cityBlockEffectToValue cityBlockType.effects) }

gameFromPortable : PortableGame -> Game
gameFromPortable portGame =
  { portGame |
      players = Dict.fromList portGame.players
    , cities = Dict.fromList portGame.cities
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
type Msg = NoOp | CreateGame | NextTurn | ReadGame PortableGame

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
        nextGame = { prevGame | turnCounter = prevGame.turnCounter + 1 }
      in
        ( { model | game = nextGame }
        , writePort (gameToPortable nextGame)
        )
    ReadGame portGame ->
      let
        nextGame = gameFromPortable portGame
      in
        ( { model | game = nextGame }, Cmd.none )


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
