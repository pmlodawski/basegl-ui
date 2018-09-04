import * as basegl         from 'basegl'
import * as Color          from 'basegl/display/Color'
import {circle}            from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {length, PortShape} from 'shape/port/Base'
import * as layers         from 'view/layers'


radius = length
export width = 2 * radius
export height = 2 * radius

export selfPortExpr = (styles) -> basegl.expr ->
    c = circle radius
       .move radius, radius
       .fill color.varHover styles

selfPortSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol selfPortExpr styles
    symbol.bbox.xy = [width, height]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.defaultZIndex = layers.selfPort
    symbol

export class SelfPortShape extends PortShape
    define: => selfPortSymbol @styles
    adjust: (element) =>
        super element
        element.position.xy = [-width/2, -height/2]
    registerEvents: (view) =>
        super view
        @watchStyles 'baseColor_r', 'baseColor_g', 'baseColor_b'
