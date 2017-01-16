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
  }

gameFromPortable : PortableGame -> Game
gameFromPortable portGame =
  { portGame |
      players = Dict.fromList portGame.players
    , cities = Dict.fromList portGame.cities
  }


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  readPort ReadGame


-- UPDATE
type Msg = NoOp | NextTurn | ReadGame PortableGame

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
          writePort (gameToPortable nextGame)
        )
    ReadGame portGame ->
      ( { model | game = (gameFromPortable portGame) }, Cmd.none )


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container" ][
    div [ class "row" ][
      gameDisplay model.game,
      button [ class "btn", onClick NextTurn ] [ text "Next Turn" ]
    ]
  ]
