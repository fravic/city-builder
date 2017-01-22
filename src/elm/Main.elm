port module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Platform exposing (..)
import Random exposing (initialSeed)

import Model exposing (..)
import Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Update.NextTurn exposing (nextTurn)

import Components.Game exposing (gameDisplay)

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
      nextTurn model
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
