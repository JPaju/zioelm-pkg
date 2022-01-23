module Page.Listing exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, centerX, centerY, column, fill, height, mouseOver, paddingXY, pointer, px, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Http
import Package exposing (Package, PackageListing)
import Route
import Ui
import Element exposing (minimum)


type alias Model =
    { listing : RemoteData Http.Error PackageListing
    , searchText : String
    }


type Msg
    = GotPackageListing (Result Http.Error PackageListing)
    | SearchTextChanged String


init : ( Model, Cmd Msg )
init =
    ( { listing = Loading
      , searchText = ""
      }
    , Api.fetchPackageListing GotPackageListing
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotPackageListing listingResult ->
            case listingResult of
                Ok listing -> 
                    ({model | listing = Finished listing}, Cmd.none)
                Err httpErr -> 
                    ({model | listing = Errored httpErr}, Cmd.none)

        SearchTextChanged searchText ->
            ( { model | searchText = searchText }, Cmd.none )

view : Model -> Element Msg
view { listing, searchText } =
    case listing of
        Loading -> Ui.loadingPage "Listing"

        Errored _ -> Ui.errorPage "Something went wrong while loading packages"

        Finished lst ->
            let
                filteredListing =
                    List.filter (\l -> String.contains searchText l.name) lst
            in
            column [ centerX, paddingXY 20 20, width (shrink |> minimum 450), spacing 50 ]
                [ Ui.pageHeader [ centerY, centerX, height (px 50) ] "All packages"
                , Ui.textInput [ centerX ] "Search packages" SearchTextChanged searchText
                , column [ spacing 5, width fill ] (List.map viewPackage filteredListing)
                ]


viewPackage : Package -> Element Msg
viewPackage pkg =
    Element.link
        [ paddingXY 20 10
        , centerX
        , width fill
        , Background.color Ui.blue
        , mouseOver [ Background.color Ui.grey ]
        , Border.rounded 20
        , pointer
        ]
        { url = Route.packageUrl pkg, label = text pkg.name }
