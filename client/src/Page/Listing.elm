module Page.Listing exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, centerX, centerY, column, fill, height, minimum, paddingXY, px, shrink, spacing, width)
import Http
import Package exposing (PackageListing, viewPackage)
import Ui


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackageListing listingResult ->
            case listingResult of
                Ok listing ->
                    ( { model | listing = Finished listing }, Cmd.none )

                Err httpErr ->
                    ( { model | listing = Errored httpErr }, Cmd.none )

        SearchTextChanged searchText ->
            ( { model | searchText = searchText }, Cmd.none )


view : Model -> Element Msg
view { listing, searchText } =
    case listing of
        Loading ->
            Ui.loadingPage "Listing"

        Errored _ ->
            Ui.errorPage "Something went wrong while loading packages"

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
