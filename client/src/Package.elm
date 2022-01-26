module Package exposing
    ( Dependency(..)
    , Package
    , PackageDetails
    , PackageId(..)
    , PackageListing
    , PackageName
    , getIdStr
    , getNameStr
    , listingDecoder
    , packageDecoder
    , packageDetailsDecoder
    , packageUrl
    , viewDependency
    , viewPackage
    )

import Element exposing (Attribute, Element, centerX, el, fill, mouseOver, padding, paddingXY, pointer, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (when)
import Json.Decode.Pipeline exposing (required)
import Ui
import Url exposing (Protocol(..))


type alias Package =
    { id : PackageId
    , name : PackageName
    }


type PackageId
    = PackageId String


type PackageName
    = PackageName String


type alias PackageDetails =
    { id : PackageId
    , name : PackageName
    , description : String
    , dependencies : List Dependency
    , reverseDependencies : List Dependency
    }


type Dependency
    = Known Package
    | Unknown { name : String }
    | Alternatives (List Dependency)


type alias PackageListing =
    List Package


getIdStr : PackageId -> String
getIdStr id =
    case id of
        PackageId idStr ->
            idStr


getNameStr : PackageName -> String
getNameStr name =
    case name of
        PackageName nameStr ->
            nameStr


packageUrl : Package -> String
packageUrl pkg =
    "/package/" ++ getIdStr pkg.id



---- VIEW ----


packageBackground : Element.Color
packageBackground =
    Ui.blue


unknownPackageBackground : Element.Color
unknownPackageBackground =
    Ui.red


dependencyAttributes : List (Attribute msg)
dependencyAttributes =
    [ paddingXY 20 10
    , centerX
    , width fill
    , Border.rounded 20
    ]


packageAttributes : List (Attribute msg)
packageAttributes =
    dependencyAttributes
        ++ [ Background.color packageBackground
           , mouseOver [ Background.color Ui.grey ]
           , pointer
           ]


viewPackage : Package -> Element msg
viewPackage pkg =
    Element.link
        packageAttributes
        { url = packageUrl pkg, label = pkg.name |> getNameStr |> text }


viewDependency : Dependency -> Element msg
viewDependency dependency =
    case dependency of
        Known package ->
            viewPackage package

        Unknown unknownDep ->
            viewUnknownDependency unknownDep

        Alternatives dependencies ->
            viewAlternatives dependencies


viewUnknownDependency : { name : String } -> Element msg
viewUnknownDependency { name } =
    el (dependencyAttributes ++ [ Background.color unknownPackageBackground ])
        (text name)


viewAlternatives : List Dependency -> Element msg
viewAlternatives dependencies =
    let
        divider =
            el [] (text " or ")

        alternatives =
            dependencies
                |> List.map viewDependency
                |> List.intersperse divider
    in
    row [ spacing 10, Border.solid, Border.width 2, padding 5, Border.rounded 20 ] alternatives



---- DECODER ----


listingDecoder : Decoder PackageListing
listingDecoder =
    Decode.list packageDecoder


packageDecoder : Decoder Package
packageDecoder =
    Decode.succeed Package
        |> required "id" idDecoder
        |> required "name" nameDecoder


idDecoder : Decoder PackageId
idDecoder =
    Decode.map PackageId Decode.string


nameDecoder : Decoder PackageName
nameDecoder =
    Decode.map PackageName Decode.string


packageDetailsDecoder : Decoder PackageDetails
packageDetailsDecoder =
    Decode.succeed PackageDetails
        |> required "id" idDecoder
        |> required "name" nameDecoder
        |> required "description" Decode.string
        |> required "dependencies" (Decode.list dependencyDecoder)
        |> required "reverseDependencies" (Decode.list dependencyDecoder)


is : a -> a -> Bool
is a b =
    a == b


dependencyDecoder : Decoder Dependency
dependencyDecoder =
    Decode.oneOf
        [ when dependencyType (is "known") knownDependencyDecoder
        , when dependencyType (is "unknown") unknownDependencyDecoder
        , when dependencyType (is "alternatives") alternativesDependencyDecoder
        ]


dependencyType : Decoder String
dependencyType =
    Decode.field "type" Decode.string


knownDependencyDecoder : Decoder Dependency
knownDependencyDecoder =
    Decode.map Known packageDecoder


unknownDependencyDecoder : Decoder Dependency
unknownDependencyDecoder =
    Decode.succeed Unknown
        |> required "name" (Decode.string |> Decode.map (\n -> { name = n }))


alternativesDependencyDecoder : Decoder Dependency
alternativesDependencyDecoder =
    let
        -- Required to parse recursive structure
        lazyPackageDecoder =
            Decode.lazy (\_ -> dependencyDecoder)
    in
    Decode.succeed Alternatives
        |> required "alternatives" (Decode.list lazyPackageDecoder)
