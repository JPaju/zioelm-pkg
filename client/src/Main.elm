module Main exposing (..)

import Api exposing (RemoteData(..))
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Element, centerX, centerY, fill, height, layout, mouseOver, paddingXY, pointer, px, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Page.Details as Details
import Page.Listing as Listing
import Route
import Ui as Ui
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { navKey : Nav.Key
    , page : Page
    }


type Page
    = ListingPage Listing.Model
    | DetailsPage Details.Model


type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url
    | GotListingMsg Listing.Msg
    | GotDetailsMsg Details.Msg



-- TODO Parse url here and show page accordingly


init : Url -> Nav.Key -> ( Model, Cmd Msg )
init url key =
    let
        ( model, cmd ) =
            Listing.init
    in
    ( { navKey = key
      , page = ListingPage model
      }
    , Cmd.map GotListingMsg cmd
    )



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
        Route.Listing ->
            updateListingPage model Listing.init

        Route.PackageDetails pkgId ->
            updateDetailsPage model (Details.init pkgId)


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



----  PAGES ----


pageLayout : Element msg -> (msg -> Msg) -> Browser.Document Msg
pageLayout content toMsg =
    { title = "Package explorer"
    , body =
        [ layout [ height fill, width fill ] (Element.map toMsg content) ]
    }


homePage : Element msg
homePage =
    row [ width fill, centerX, centerY, spacing 20 ]
        [ navLink "Zsh" "/zsh"
        , navLink "Gawk" "/gawk"
        ]


navLink : String -> String -> Element msg
navLink label href =
    Element.link
        [ centerX
        , width (px 300)
        , Font.color Ui.white
        , Font.center
        , Font.size 32
        , Background.color Ui.blue
        , mouseOver [ Background.color Ui.black ]
        , Border.rounded 10
        , paddingXY 20 50
        , pointer
        ]
        { url = href, label = Element.text label }



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
