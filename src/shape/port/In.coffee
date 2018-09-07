import * as basegl         from 'basegl'
import * as Animation      from 'basegl/animation/Animation'
import * as Easing         from 'basegl/animation/Easing'
import * as Color          from 'basegl/display/Color'
import {circle, pie, rect} from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {nodeRadius}        from 'shape/node/Base'
import * as layers         from 'view/layers'
import {width, length, offset, angle, inArrowRadius, distanceFromCenter, PortShape}  from 'shape/port/Base'


activeAreaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 1.5
bboxHeight = 2 *  bboxWidth * Math.tan activeAreaAngle

inPortExpr = (style) -> basegl.expr ->
    r = inArrowRadius
    c = circle r
       .move bboxWidth/2, 0
    p = pie angle
       .rotate Math.PI
       .move bboxWidth/2, distanceFromCenter
    port = c * p
    port = port.fill color.varAlphaHover style
    activeCutter = circle nodeRadius
        .move bboxWidth/2, 0
    activeArea = pie activeAreaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + port

inPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol inPortExpr style
    symbol.bbox.xy = [bboxWidth, bboxHeight]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.color_a = 1
    symbol.variables.hovered = 0
    symbol.defaultZIndex = layers.inPort
    symbol

export class InPortShape extends PortShape
    define: => inPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth/2, -distanceFromCenter - offset]
