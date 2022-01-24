module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), string)


type Route
    = Listing
    | PackageDetails PackageId


type alias PackageId =
    String


fromUrl : Url -> Route
fromUrl =
    Parser.parse parser >> Maybe.withDefault Listing


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Listing Parser.top
        , Parser.map PackageDetails (Parser.s "package" </> string)
        ]
