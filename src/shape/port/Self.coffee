import * as basegl         from 'basegl'
import * as Color          from 'basegl/display/Color'
import {circle}            from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {length, PortShape} from 'shape/port/Base'
import * as layers         from 'view/layers'


radius = (style) -> style.port_length
export width = (style) -> 2 * radius(style)
export height = (style) -> 2 * radius(style)

export selfPortExpr = (style) -> basegl.expr ->
    c = circle radius(style)
       .move radius(style), radius(style)
       .fill color.varHover style

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
