port module Main exposing (..)

import Html
import Platform exposing (..)
import Random exposing (initialSeed)

import Model exposing (..)
import Ports exposing (gameFromPortable, gameToPortable, readPort, writePort)

import Game.State
import Game.View
import Msg exposing (Msg)

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
subscriptions model = Game.State.subscriptions model.game |> Sub.map Msg.MsgForGame


-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msg.NoOp -> (model, Cmd.none)
    Msg.MsgForGame msg ->
      let
        (nextGame, nextRandSeed) = Game.State.update msg model.randomSeed model.game
      in
        ({ model | game = nextGame, randomSeed = nextRandSeed }, writePort (gameToPortable nextGame))


-- VIEW
view : Model -> Html.Html Msg
view model = Html.map Msg.MsgForGame (Game.View.view model.game)
