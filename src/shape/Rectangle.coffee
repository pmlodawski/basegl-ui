import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'


export rectangleExpr = (style) -> basegl.expr ->
    rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.varHSLAlpha style

rectangleSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol rectangleExpr style
    symbol.defaultZIndex = layers.textFrame
    symbol.variables.color_h = 0
    symbol.variables.color_s = 0
    symbol.variables.color_l = 0
    symbol.variables.color_a = 0
    symbol

export class RectangleShape extends BasicComponent
    initModel: =>
        width: 0
        height: 0
        color: null

    define: =>
        rectangleSymbol @style

    adjust: (element, view) =>
        if @changed.width
            element.bbox.x = @model.width
        if @changed.height
            element.bbox.y = @model.height
        if @changed.color
            element.variables.color_a = Number @model.color?
            if @model.color?
                element.variables.color_h = @model.color[0]
                element.variables.color_s = @model.color[1]
                element.variables.color_l = @model.color[2]
                element.variables.color_a = @model.color[3] or 1
