module Page.Details exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, column, el, text)
import Http
import Package exposing (PackageDetails)
import Ui


type alias Model =
    { details : RemoteData Http.Error PackageDetails
    }


type Msg
    = GotPackageDetails (Result Http.Error PackageDetails)


init : String -> ( Model, Cmd Msg )
init pkgId =
    ( { details = Loading }, Api.fetchPackageDetails pkgId GotPackageDetails )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackageDetails detailsResult ->
            case detailsResult of
                Ok details ->
                    ( { model | details = Finished details }, Cmd.none )

                Err httpErr ->
                    ( { model | details = Errored httpErr }, Cmd.none )


view : Model -> Element Msg
view { details } =
    case details of
        Loading ->
            Ui.loadingPage "Details"

        Errored _ ->
            Ui.errorPage "Something went wrong while loading details "

        Finished packageDetails ->
            let
                detailsText =
                    "Showing information about " ++ packageDetails.name ++ ". Description: " ++ packageDetails.description
            in
            column [] [ el [] (text detailsText) ]
