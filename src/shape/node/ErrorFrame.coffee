import * as basegl    from 'basegl'
import * as Color     from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import {vector}         from 'basegl/math/Vector'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import * as baseNode    from 'shape/node/Base'


errorFrame = 20.0
errorWidth = (style) -> baseNode.width(style) + errorFrame
errorHeight = (style) -> baseNode.height(style) + errorFrame
stripeWidth = 30.0
rotation = Math.PI * 3 / 4
start = errorFrame/3

compactNodeErrorExpr = (style) -> basegl.expr ->
    frame = baseNode.compactNodeExpr(style).grow errorFrame
           .fill Color.rgb [1,0,0]
    stripe = rect 1000, stripeWidth
            .repeat vector(0, 1), stripeWidth
            .move 0, start
            .rotate rotation
    frame * stripe

compactNodeErrorSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol compactNodeErrorExpr style
    symbol.defaultZIndex = layers.compactNodeError
    symbol.variables.selected = 0
    symbol.bbox.xy = [errorWidth(style), errorHeight(style)]
    symbol

export class NodeErrorShape extends BasicComponent
    initModel: =>
        body:     [100, 100]
    define: =>
        compactNodeErrorSymbol @style

    adjust: (element) =>
        if @model.expanded
            element.variables.bodyWidth  = @model.body[0]
            element.variables.bodyHeight = @model.body[1]
            element.position.xy = [-baseNode.width(@style)/2, -@model.body[1] - baseNode.height(@style)/2 - @style.node_headerOffset]
        else
            element.position.xy = [-baseNode.width(@style)/2, -baseNode.height(@style)/2]
