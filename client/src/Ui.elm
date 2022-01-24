module Ui exposing
    ( blue
    , errorPage
    , grey
    , indigo
    , loadingPage
    , loadingSpinner
    , notFoundPage
    , pageHeader
    , red
    , subHeader
    , textInput
    )

import Element exposing (Attribute, Color, Element, centerX, centerY, column, el, fill, height, maximum, row, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Widget exposing (circularProgressIndicator)
import Widget.Material exposing (defaultPalette, progressIndicator)


spinnerStyles : Widget.ProgressIndicatorStyle msg
spinnerStyles =
    progressIndicator defaultPalette



---- COMPONENTS ----


loadingSpinner : List (Attribute msg) -> Element msg
loadingSpinner attrs =
    circularProgressIndicator spinnerStyles Nothing
        |> el attrs


pageHeader : List (Attribute msg) -> String -> Element msg
pageHeader attributes headerText =
    el (attributes ++ [ Region.heading 2, Font.size 32, Font.semiBold ]) (text headerText)


subHeader : List (Attribute msg) -> String -> Element msg
subHeader attributes headerText =
    el (attributes ++ [ Region.heading 3, Font.size 24, Font.semiBold ]) (text headerText)


textInput : List (Attribute msg) -> String -> (String -> msg) -> String -> Element msg
textInput attributes label onChange value =
    let
        defaultAttributes =
            [ width (fill |> maximum 300) ]

        labelText =
            text label
    in
    Input.text (attributes ++ defaultAttributes)
        { onChange = onChange
        , text = value
        , placeholder =
            labelText
                |> Input.placeholder []
                |> Just
        , label =
            labelText
                |> Input.labelAbove [ Font.size 12, Font.alignLeft, Font.color grey ]
        }



---- PAGES ----


loadingPage : String -> Element msg
loadingPage description =
    column [ centerX, centerY, spacing 25 ]
        [ text ("Loading " ++ description)
        , loadingSpinner [ centerX, centerY ]
        ]


errorPage : String -> Element msg
errorPage errorMessage =
    row [ centerX, centerY, spacing 20 ]
        [ text errorMessage
        ]


notFoundPage : Element msg
notFoundPage =
    column [ width fill, height fill ]
        [ el [ centerX, centerY, Font.size 36 ] (text "404: Page not found") ]


red : Color
red =
    Element.rgb255 249 28 114


blue : Color
blue =
    Element.rgb255 95 171 220


indigo : Color
indigo =
    Element.rgb255 153 140 221


grey : Color
grey =
    Element.rgb255 224 224 224
