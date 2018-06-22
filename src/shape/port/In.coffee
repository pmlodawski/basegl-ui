import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie, rect}  from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/node/Base'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as layers       from 'view/layers'
import {width, length, angle, inArrowRadius, distanceFromCenter}  from 'shape/port/Base'


export inPortExpr = basegl.expr ->
    r = inArrowRadius
    c = circle r
       .move width/2, -distanceFromCenter
    p = pie angle
       .rotate Math.PI
       .move width/2, 0
    port = c * p
    port.fill Color.rgb ['color_r', 'color_g', 'color_b']


inPortSymbol = basegl.symbol inPortExpr
inPortSymbol.bbox.xy = [width,length]
inPortSymbol.variables.color_r = 1
inPortSymbol.variables.color_g = 0
inPortSymbol.variables.color_b = 0
inPortSymbol.defaultZIndex = layers.inPort

export class InPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => inPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-width/2, -length/2]

