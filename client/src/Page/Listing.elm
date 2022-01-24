module Page.Listing exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, centerX, centerY, column, fill, height, minimum, paddingXY, px, shrink, spacing, width)
import Http
import Package exposing (PackageListing, viewPackage)
import Ui


type alias Model =
    { remoteListing : RemoteData Http.Error PackageListing
    , searchText : String
    }


type Msg
    = GotPackageListing (Result Http.Error PackageListing)
    | SearchTextChanged String


init : ( Model, Cmd Msg )
init =
    ( { remoteListing = Loading
      , searchText = ""
      }
    , Api.fetchPackageListing GotPackageListing
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackageListing listingResult ->
            case listingResult of
                Ok listing ->
                    ( { model | remoteListing = Finished listing }, Cmd.none )

                Err httpErr ->
                    ( { model | remoteListing = Errored httpErr }, Cmd.none )

        SearchTextChanged searchText ->
            ( { model | searchText = searchText }, Cmd.none )


view : Model -> Element Msg
view { remoteListing, searchText } =
    case remoteListing of
        Loading ->
            Ui.loadingPage "Listing"

        Errored _ ->
            Ui.errorPage "Something went wrong while loading packages"

        Finished listing ->
            viewListing listing searchText


viewListing : PackageListing -> String -> Element Msg
viewListing listing searchText =
    let
        filteredListing =
            List.filter (\l -> String.contains searchText l.name) listing
    in
    column [ centerX, paddingXY 20 20, width (shrink |> minimum 450), spacing 50 ]
        [ Ui.pageHeader [ centerY, centerX, height (px 50) ] "All packages"
        , Ui.textInput [ centerX ] "Search packages" SearchTextChanged searchText
        , column [ spacing 5, width fill, centerX ] (List.map viewPackage filteredListing)
        ]
