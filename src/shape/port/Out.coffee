import * as basegl                  from 'basegl'
import * as Color                   from 'basegl/display/Color'
import {circle, pie}                from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/node/Base'
import {BasicComponent}             from 'abstract/BasicComponent'
import * as layers                  from 'view/layers'
import {width, length, angle, outArrowRadius}  from 'shape/port/Base'


export outPortExpr = basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move width/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move width/2, h2 + r
    port = p - c
    port.move 0, -r+length-h2
        .fill Color.rgb ['color_r', 'color_g', 'color_b']

outPortSymbol = basegl.symbol outPortExpr
outPortSymbol.bbox.xy = [width,length]
outPortSymbol.variables.color_r = 1
outPortSymbol.variables.color_g = 0
outPortSymbol.variables.color_b = 0
outPortSymbol.defaultZIndex = layers.outPort

export class OutPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => outPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-width/2, -length/2]
