module Package exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Url exposing (Protocol(..))


type alias Package =
    { id : String
    , name : String
    }


type alias PackageDetails =
    { id : String
    , name : String
    , description : String
    , dependencies : List Dependency
    , reverseDependency : List Dependency
    }


type Dependency
    = Known Package
    | Unknown { name : String }
    | Alternatives Dependency


type PackageReference
    = KnownPackage Package
    | UnknownPackage { name : String }


type alias PackageListing =
    List Package


packageDecoder : Decoder Package
packageDecoder =
    Decode.succeed Package
        |> required "id" Decode.string
        |> required "name" Decode.string


packageDetailsDecoder : Decoder PackageDetails
packageDetailsDecoder =
    Decode.succeed PackageDetails
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "description" Decode.string
        |> required "dependencies" (Decode.succeed [])
        |> required "reverseDependencies" (Decode.succeed [])


listingDecoder : Decoder PackageListing
listingDecoder =
    Decode.list packageDecoder
