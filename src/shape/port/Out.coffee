import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle, pie}    from 'basegl/display/Shape'
import {nodeRadius}     from 'shape/node/Base'
import * as color       from 'shape/Color'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import {width, length, angle, outArrowRadius, distanceFromCenter, PortShape}  from 'shape/port/Base'

areaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 1.5
bboxHeight = 2 *  bboxWidth * Math.tan areaAngle

export outPortExpr = (styles) -> basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move bboxWidth/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move bboxWidth/2, h2 + r
    port = p - c
    port = port.move 0, - r + length - h2 + distanceFromCenter
        .fill color.varHover styles
    activeCutter = circle nodeRadius
        .move bboxWidth/2, 0
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + port

outPortSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol outPortExpr styles
    symbol.bbox.xy = [bboxWidth,bboxHeight]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.defaultZIndex = layers.outPort
    symbol

export class OutPortShape extends PortShape
    define: => outPortSymbol @styles
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth/2, -distanceFromCenter]
    registerEvents: (view) =>
        super view
        @watchStyles 'baseColor_r', 'baseColor_g', 'baseColor_b'
