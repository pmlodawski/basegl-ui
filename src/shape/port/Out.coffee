import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle, pie}    from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import {width, length, offset, angle, outArrowRadius, distanceFromCenter, PortShape}  from 'shape/port/Base'

areaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 1.5
bboxHeight = 2 *  bboxWidth * Math.tan areaAngle

export outPortExpr = (style) -> basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move bboxWidth/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move bboxWidth/2, h2 + r
    port = p - c
    port = port.move 0, - r + length - h2 + distanceFromCenter
        .fill color.varHover style
    activeCutter = circle style.nodeRadius
        .move bboxWidth/2, 0
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + port

outPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol outPortExpr style
    symbol.bbox.xy = [bboxWidth,bboxHeight]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.defaultZIndex = layers.outPort
    symbol

export class OutPortShape extends PortShape
    define: => outPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth/2, -distanceFromCenter - offset]
