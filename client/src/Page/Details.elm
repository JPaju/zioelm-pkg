module Page.Details exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, centerX, column, el, fill, maximum, paragraph, spacing, text, width)
import Html exposing (details)
import Http
import Package exposing (Dependency(..), PackageDetails, viewDependency)
import Ui


type alias Model =
    { remoteDetails : RemoteData Http.Error PackageDetails
    }


type Msg
    = GotPackageDetails (Result Http.Error PackageDetails)


init : String -> ( Model, Cmd Msg )
init pkgId =
    ( { remoteDetails = Loading }, Api.fetchPackageDetails pkgId GotPackageDetails )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPackageDetails detailsResult ->
            case detailsResult of
                Ok details ->
                    ( { model | remoteDetails = Finished details }, Cmd.none )

                Err httpErr ->
                    ( { model | remoteDetails = Errored httpErr }, Cmd.none )


view : Model -> Element Msg
view { remoteDetails } =
    case remoteDetails of
        Loading ->
            Ui.loadingPage "Details"

        Errored _ ->
            Ui.errorPage "Something went wrong while loading package details"

        Finished details ->
            viewDetails details


viewDetails : PackageDetails -> Element msg
viewDetails { name, description, dependencies, reverseDependencies } =
    let
        header =
            Ui.pageHeader [ centerX ] ("Package: " ++ name)

        info =
            column [ centerX, width (fill |> maximum 700), spacing 50 ]
                [ detailsPageSection "Description" (paragraph [] [ el [] (text description) ])
                , detailsPageSection "Dependencies" (viewDependencies dependencies)
                , detailsPageSection "Reverse dependencies" (viewDependencies reverseDependencies)
                ]
    in
    column [ width fill, spacing 20 ] [ header, info ]


detailsPageSection : String -> Element msg -> Element msg
detailsPageSection sectionTitle content =
    column [ spacing 10 ]
        [ Ui.subHeader [] sectionTitle
        , content
        ]


viewDependencies : List Dependency -> Element msg
viewDependencies dependencies =
    column [ spacing 10 ] (List.map viewDependency dependencies)
