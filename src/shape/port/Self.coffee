import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle}         from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import {length}         from 'shape/port/Base'


radius = length
export width = 2 * radius
export height = 2 * radius

export selfPortExpr = basegl.expr ->
    c = circle radius
       .move radius, radius
       .fill Color.rgb ['color_r', 'color_g', 'color_b']

selfPortSymbol = basegl.symbol selfPortExpr
selfPortSymbol.bbox.xy = [width, height]
selfPortSymbol.variables.color_r = 1
selfPortSymbol.variables.color_g = 0
selfPortSymbol.variables.color_b = 0
selfPortSymbol.defaultZIndex = layers.selfPort

export class SelfPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => selfPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-width/2, -height/2]

