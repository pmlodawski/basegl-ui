import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Color       from 'basegl/display/Color'
import {pie}            from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'

angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle

export flatPortExpr = basegl.expr ->
    p = pie -angle
       .rotate -Math.PI /2
       .move length + 1, width/2
       .fill Color.rgb ['color_r', 'color_g', 'color_b']

flatPortSymbol = basegl.symbol flatPortExpr
flatPortSymbol.bbox.xy = [length, width]
flatPortSymbol.variables.color_r = 1
flatPortSymbol.variables.color_g = 0
flatPortSymbol.variables.color_b = 0
flatPortSymbol.defaultZIndex = layers.flatPort

export class FlatPortShape extends BasicComponent
    initModel: =>
        color: [1,0,0]
    define: => flatPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        if @changed.once
            element.position.xy = [0, -width/2]
