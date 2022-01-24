module Page.Details exposing (..)

import Api exposing (RemoteData(..))
import Element exposing (Element, centerX, column, el, fill, maximum, paragraph, spacing, text, width)
import Http
import Package exposing (Dependency(..), PackageDetails, viewDependency)
import Ui
import Html exposing (details)


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
                headerText =
                    "Package: " ++ packageDetails.name
            in
            column [ width fill, spacing 20 ]
                [ Ui.pageHeader [ centerX ] headerText
                , viewDetails packageDetails
                ]


viewDetails : PackageDetails -> Element msg
viewDetails { description, dependencies, reverseDependencies } =
    column [ centerX, width (fill |> maximum 700), spacing 50 ]
        [ detailsPageSection "Description" (paragraph [] [ el [] (text description) ])
        , detailsPageSection "Dependencies" (viewDependencies dependencies)
        , detailsPageSection "Reverse dependencies"  (viewDependencies reverseDependencies)
        ]


detailsPageSection : String -> Element msg -> Element msg
detailsPageSection sectionTitle content =
    column [ spacing 10 ]
        [ Ui.subHeader [] sectionTitle
        , content
        ]


viewDependencies : List Dependency -> Element msg
viewDependencies dependencies =
    column [ spacing 10 ] (List.map viewDependency dependencies)
