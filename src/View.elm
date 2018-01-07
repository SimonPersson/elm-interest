module View exposing (view)

import AccumulatedInterest exposing (accumulatedInterest)
import FormatNumber
import FormatNumber.Locales exposing (frenchLocale)
import Html exposing (Attribute, Html, br, div, h3, input, label, option, p, select, text)
import Html.Attributes exposing (class, id, maxlength, placeholder, type_, value)
import Html.Events exposing (onCheck, onInput)
import LineChart exposing (lineChart)
import Model exposing (Model, initialState)
import Msg exposing (Msg(..), ParamUpdate(..))


view : Model -> Html Msg
view model =
    let
        dataPoints =
            accumulatedInterest model.firstParam model.currentDate

        finalNumber =
            Maybe.withDefault 0 <| Maybe.map Tuple.second <| List.head <| List.reverse dataPoints

        formattedBalance =
            FormatNumber.format { frenchLocale | decimals = 2 } finalNumber

        simpleParamForms =
            [ div [ class "input-box" ]
                [ label [] [ text "Yearly Return:" ]
                , if model.showAdvanced then
                    input [ placeholder <| toString initialState.firstParam.interest ++ "%", onInput (NewParam 0 << Interest) ] []
                  else
                    let
                        stockReturn =
                            toString initialState.firstParam.interest
                    in
                    select [ onInput (NewParam 0 << Interest) ]
                        [ option [ value stockReturn ]
                            [ text ("Stocks: " ++ stockReturn ++ "%") ]
                        , option [ value "3.5" ] [ text "Bonds: 3.5%" ]
                        , option [ value "-1" ] [ text "Savings Account: -1%" ]
                        ]
                ]
            , div [ class "input-box" ]
                [ label [] [ text "Starting Principal:" ]
                , input [ placeholder <| toString initialState.firstParam.initialPrincipal ++ " EUR", onInput (NewParam 0 << Principal) ] []
                ]
            , div [ class "input-box" ]
                [ label [] [ text "Monthly Contribution:" ]
                , input [ placeholder <| toString initialState.firstParam.contribution ++ " EUR", onInput (NewParam 0 << Contribution) ] []
                ]
            , div [ class "input-box" ]
                [ label [] [ text "Duration (years):" ]
                , input [ placeholder <| toString initialState.firstParam.years, onInput (NewParam 0 << Duration), maxlength 2 ] []
                ]
            ]

        advancedParamForms =
            [ div [ class "input-box" ]
                [ label [] [ text "Contribution Growth:" ]
                , input [ placeholder <| toString initialState.firstParam.contributionGrowthRate ++ " %", onInput (NewParam 0 << ContributionRate) ] []
                ]
            , div [ class "input-box" ]
                [ label [] [ text "Compound Frequency:" ]
                , select [ onInput (NewParam 0 << CompoundPerYear) ]
                    [ option [ value "1" ] [ text "Yearly" ]
                    , option [ value "6" ] [ text "Semi Anually" ]
                    , option [ value "12" ] [ text "Monthly" ]
                    , option [ value "365" ] [ text "Daily" ]
                    ]
                ]
            ]
    in
    div []
        [ div [ class "row" ]
            [ h3 [ class "left" ] [ text "Settings:" ]
            ]
        , div [ class "row" ]
            (if model.showAdvanced then
                simpleParamForms ++ advancedParamForms
             else
                simpleParamForms
            )
        , div [ class "row" ]
            [ label [] [ text "Show advanced parameters:" ]
            , input [ type_ "checkbox", onCheck ShowAdvanced ] []
            ]
        , div [ class "row" ]
            [ h3 [] [ text <| "Final balance: " ++ formattedBalance ]
            ]
        , div [ class "row", id "plot" ]
            [ lineChart <| dataPoints
            ]
        ]
