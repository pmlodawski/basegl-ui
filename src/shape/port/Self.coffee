import * as basegl         from 'basegl'
import * as Color          from 'basegl/display/Color'
import {circle, rect}            from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {length, PortShape} from 'shape/port/Base'
import * as layers         from 'view/layers'


radius = (style) -> style.port_selfRadius
export width = (style) -> 2 * radius(style)
export height = (style) -> 2 * radius(style)

export selfPortExpr = (style) -> basegl.expr ->
    c = circle radius(style)
       .move radius(style), radius(style)
       .fill color.varHover style
    stripe2 = rect radius(style)*0.92, radius(style)*0.25, 1
        .move radius(style), radius(style)
        .fill Color.rgb [1, 1, 1, 1]
    stripe1 = stripe2.moveY radius(style)*0.33
    stripe3 = stripe2.moveY -radius(style)*0.33
        .fill Color.rgb [172/256, 195/256, 253/256]
    c + stripe1 + stripe2 + stripe3

selfPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol selfPortExpr style
    symbol.bbox.xy = [width(style), height(style)]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.defaultZIndex = layers.selfPort
    symbol

export class SelfPortShape extends PortShape
    define: => selfPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-width(@style)/2, -height(@style)/2]
