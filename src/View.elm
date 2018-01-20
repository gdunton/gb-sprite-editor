module View exposing (view)

import Matrix exposing (matrixAt)
import Model exposing (Color(..), Model, Msg(..), ColorChangeEvent, Canvas)
import Sprite exposing (createHexOutput)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (..)
import Json.Decode as Json


-- Exposed Functions


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Gameboy Sprite Editor" ]
        , createPallete model
        , createTools
        , div [ class "buttons" ]
            (createViewGrid model)
        , createOutput model.grid
        ]



-- Private Functions


colorToHex : Color -> String
colorToHex color =
    case color of
        W ->
            "#9bbc0f"

        L ->
            "#83a30e"

        D ->
            "#306230"

        B ->
            "#0f380f"


onTouchStart : a -> Attribute a
onTouchStart action =
    on "touchstart" (Json.succeed action)


onTouchEnd : a -> Attribute a
onTouchEnd action =
    on "touchend" (Json.succeed action)


createButton : Model -> Int -> Html Msg
createButton model index =
    let
        x =
            (index % 8)

        y =
            (index // 8)

        color =
            (matrixAt x y model.grid) |> withDefault W |> colorToHex
    in
        button
            [ onClick (ColorChanged (ColorChangeEvent x y model.brush))
            , style [ ( "backgroundColor", color ) ]
            , onTouchStart (ColorChanged (ColorChangeEvent x y model.brush))
            , onTouchEnd Noop
            ]
            []


createViewGrid : Model -> List (Html Msg)
createViewGrid model =
    List.range 0 63
        |> List.map (createButton model)


createPalletButton : Color -> Model -> Html Msg
createPalletButton color model =
    let
        s =
            if color == model.brush then
                "black"
            else
                "white"
    in
        button
            [ onClick (BrushChanged color)
            , style
                [ ( "background-color", (colorToHex color) )
                , ( "border", "2px solid " ++ s )
                , ( "border-radius", "3px" )
                ]
            ]
            []


createPallete : Model -> Html Msg
createPallete model =
    div [ class "pallete" ]
        [ h2 [] [ text "Pallete" ]
        , createPalletButton W model
        , createPalletButton L model
        , createPalletButton D model
        , createPalletButton B model
        ]


createTools : Html Msg
createTools =
    div [ class "tools" ]
        [ button [ onClick FillGrid ] [ text "fill" ]
        ]


createOutput : Canvas -> Html Msg
createOutput canvas =
    div [ class "output" ]
        ((createHexOutput canvas)
            |> List.map (\x -> Html.p [] [ text x ])
            |> (::) (Html.p [] [ text "Output" ])
        )
