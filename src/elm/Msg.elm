module Msg exposing (..)

import Game.Msg as Game

type Msg = NoOp | MsgForGame Game.Msg
