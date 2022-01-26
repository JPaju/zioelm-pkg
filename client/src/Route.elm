module Route exposing (Route(..), fromUrl)

import Package exposing (PackageId(..))
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))


type Route
    = Listing
    | PackageDetails PackageId


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Listing <| Parser.top
        , Parser.map PackageDetails <| Parser.s "package" </> packageIdParser
        ]


packageIdParser : Parser.Parser (PackageId -> a) a
packageIdParser =
    Parser.map PackageId Parser.string
