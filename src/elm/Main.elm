port module Main exposing (..)

import Html
import Platform exposing (..)
import Random exposing (initialSeed)

import Types exposing (..)
import Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Game.State
import Game.View

-- APP
main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }

type alias Flags = { startTime: Int }

init : Flags -> (Model, Cmd Msg)
init flags =
  ( Model Game.State.initial (Random.initialSeed flags.startTime)
  , Cmd.none
  )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Game.State.subscriptions model.game |> Sub.map MsgForGame


-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    MsgForGame msg ->
      let
        (nextGame, nextRandSeed) = Game.State.update msg model.randomSeed model.game
      in
        ({ model | game = nextGame, randomSeed = nextRandSeed }, writePort (gameToPortable nextGame))


-- VIEW
view : Model -> Html.Html Msg
view model = Game.View.view model.game
