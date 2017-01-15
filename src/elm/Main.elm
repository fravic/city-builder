port module Main exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Components.Game exposing ( game )


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
type alias Model = {
  game: Game
}

type alias Game = {
  turnCounter: Int
}

initialGame : Game
initialGame =
  { turnCounter = 0
  }

init : (Model, Cmd Msg)
init =
  ( Model initialGame,
    Cmd.none
  )


-- PORTS
port write : Game -> Cmd msg
port read : (Game -> msg) -> Sub msg


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  read ReadGame


-- UPDATE
type Msg = NoOp | NextTurn | ReadGame Game

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    NextTurn ->
      let
        prevGame = model.game
        nextGame = { prevGame | turnCounter = prevGame.turnCounter + 1 }
      in
        (
          { model | game = nextGame },
          write model.game
        )
    ReadGame nextGame ->
      ( { model | game = nextGame }, Cmd.none )


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container" ][
    div [ class "row" ][
      game model.game.turnCounter,
      button [ class "btn", onClick NextTurn ] [ text "Next Turn" ]
    ]
  ]
