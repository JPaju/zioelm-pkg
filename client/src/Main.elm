module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Element, alignRight, centerX, column, el, fill, height, inFront, layout, link, mouseOver, paddingXY, px, row, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Page.Details as Details
import Page.Listing as Listing
import Route
import Ui exposing (notFoundPage)
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { navKey : Nav.Key
    , page : Page
    }


type Page
    = ListingPage Listing.Model
    | DetailsPage Details.Model
    | NotFound


type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url
    | GotListingMsg Listing.Msg
    | GotDetailsMsg Details.Msg


init : Url -> Nav.Key -> ( Model, Cmd Msg )
init url key =
    let
        defaultModel =
            { navKey = key, page = NotFound }
    in
    urlChanged defaultModel url



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            ( model, linkClicked model urlRequest )

        ( UrlChanged url, _ ) ->
            urlChanged model url

        ( GotListingMsg listingMsg, ListingPage listingModel ) ->
            updateListingPage model (Listing.update listingMsg listingModel)

        ( GotDetailsMsg detailsgMsg, DetailsPage detailsModel ) ->
            updateDetailsPage model (Details.update detailsgMsg detailsModel)

        ( _, _ ) ->
            ( model, Cmd.none )


linkClicked : Model -> UrlRequest -> Cmd Msg
linkClicked model urlRequest =
    case urlRequest of
        Browser.Internal url ->
            Nav.pushUrl model.navKey (Url.toString url)

        Browser.External href ->
            Nav.load href


urlChanged : Model -> Url -> ( Model, Cmd Msg )
urlChanged model url =
    case Route.fromUrl url of
        Just Route.Listing ->
            updateListingPage model Listing.init

        Just (Route.PackageDetails pkgId) ->
            updateDetailsPage model (Details.init pkgId)

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


updateListingPage : Model -> ( Listing.Model, Cmd Listing.Msg ) -> ( Model, Cmd Msg )
updateListingPage model ( listingModel, listingCmd ) =
    ( { model | page = ListingPage listingModel }
    , Cmd.map GotListingMsg listingCmd
    )


updateDetailsPage : Model -> ( Details.Model, Cmd Details.Msg ) -> ( Model, Cmd Msg )
updateDetailsPage model ( detailsModel, detailsCmd ) =
    ( { model | page = DetailsPage detailsModel }
    , Cmd.map GotDetailsMsg detailsCmd
    )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    case model.page of
        ListingPage listingModel ->
            pageLayout (Listing.view listingModel) GotListingMsg

        DetailsPage packageDetails ->
            pageLayout (Details.view packageDetails) GotDetailsMsg

        NotFound ->
            pageLayout notFoundPage never


pageLayout : Element msg -> (msg -> Msg) -> Browser.Document Msg
pageLayout content toMsg =
    let
        pageContent =
            column [ height fill, width fill, spacingXY 0 30 ]
                [ topBar
                , Element.map toMsg content
                ]
    in
    { title = "Package explorer"
    , body = [ layout [ inFront topBar ] pageContent ]
    }


topBar : Element msg
topBar =
    let
        title =
            el [ Font.size 36, centerX ] (text "Package Explorer")

        homeLink =
            link
                [ paddingXY 10 10
                , alignRight
                , Background.color Ui.blue
                , Border.rounded 20
                , mouseOver [ Background.color Ui.grey ]
                ]
                { url = "/", label = text "Home" }
    in
    row [ width fill, height (px 70), Background.color Ui.indigo, paddingXY 50 5 ]
        [ title, homeLink ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = always init
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
