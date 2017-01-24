module Game.City.Model exposing (..)

type alias City = {
  id: String,
  name: String,
  cityBlockIds: List String
}
