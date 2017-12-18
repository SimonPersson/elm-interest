module LineChart exposing (lineChart)

import Date exposing (Month(..))
import Date.Extra.Create exposing (dateFromFields)
import Html
import Plot exposing (..)
import Svg.Attributes exposing (stroke)


lineChart : List ( Date.Date, Float ) -> Html.Html msg
lineChart data =
    let
        margin =
            defaultSeriesPlotCustomizations.margin

        newMargin =
            { margin | left = 100, right = 100, top = 100, bottom = 100 }

        newCustom =
            { defaultSeriesPlotCustomizations | margin = newMargin, horizontalAxis = horizontalAxis }
    in
    viewSeriesCustom newCustom
        [ customLineSeries ]
        data


yearFraction : Date.Date -> Float
yearFraction d =
    let
        firstOfYear y =
            dateFromFields y Jan 0 0 0 0 0

        prev =
            Date.toTime <| firstOfYear <| Date.year d

        next =
            Date.toTime <| firstOfYear <| 1 + Date.year d

        time =
            Date.toTime d

        yearFraction =
            (time - prev) / (next - prev)
    in
    yearFraction + (toFloat <| Date.year d)


yearPositions : AxisSummary -> List Float
yearPositions summary =
    let
        offset =
            (toFloat <| ceiling summary.min) - summary.min

        diff =
            summary.max - summary.min

        spacing =
            if diff < 5 then
                1
            else if diff < 10 then
                2
            else if diff < 25 then
                5
            else
                10
    in
    interval offset spacing summary


horizontalAxis =
    customAxis <|
        \summary ->
            let
                axisLine =
                    simpleLine summary
            in
            { position = closestToZero
            , axisLine = Just { axisLine | end = Maybe.withDefault 0 <| List.maximum <| yearPositions summary }
            , ticks = List.map simpleTick (yearPositions summary)
            , labels = List.map simpleLabel (yearPositions summary)
            , flipAnchor = False
            }



-- Used as a workaround as the provided axis in a line plot doesn't reach the last tick.


customLineSeries =
    { axis =
        customAxis <|
            \summary ->
                let
                    axisLine =
                        simpleLine summary

                    tickPositions =
                        decentPositions summary |> remove 0
                in
                { position = closestToZero
                , axisLine = Just { axisLine | end = Maybe.withDefault 0 <| List.maximum tickPositions }
                , ticks = List.map simpleTick tickPositions
                , labels = List.map simpleLabel (decentPositions summary |> remove 0)
                , flipAnchor = False
                }
    , interpolation = Linear Nothing [ stroke "#000000" ]
    , toDataPoints = List.map (\( x, y ) -> clear (yearFraction x) y)
    }
