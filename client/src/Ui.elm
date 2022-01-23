module Ui exposing (black, blue, grey, loadingSpinner, pageHeader, red, textInput, white, loadingPage, errorPage)

import Element exposing (Attribute, Color, Element, el, fill, maximum, text, width)
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Widget exposing (circularProgressIndicator)
import Widget.Material exposing (defaultPalette, progressIndicator)
import Element exposing (column)
import Element exposing (centerX)
import Element exposing (centerY)
import Element exposing (spacing)
import Element exposing (row)


spinnerStyles : Widget.ProgressIndicatorStyle msg
spinnerStyles =
    progressIndicator defaultPalette


loadingSpinner : List (Attribute msg) -> Element msg
loadingSpinner attrs =
    circularProgressIndicator spinnerStyles Nothing
        |> el attrs


pageHeader : List (Attribute msg) -> String -> Element msg
pageHeader attributes title =
    el (attributes ++ [ Region.heading 2, Font.size 32, Font.semiBold ]) (text title)


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


red : Color
red =
    Element.rgb255 249 28 114


blue : Color
blue =
    Element.rgb255 95 171 220


grey : Color
grey =
    Element.rgb255 224 224 224


black : Color
black =
    Element.rgb255 0 0 0


white : Color
white =
    Element.rgb255 255 255 255
