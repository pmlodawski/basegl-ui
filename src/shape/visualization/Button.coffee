import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

width = 20
height = 20

export buttonExpr = basegl.expr ->
    rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.varAlpha()

buttonSymbol = basegl.symbol buttonExpr
buttonSymbol.defaultZIndex = layers.textFrame
buttonSymbol.variables.color_r = 1
buttonSymbol.variables.color_g = 0
buttonSymbol.variables.color_b = 0
buttonSymbol.variables.color_a = 1
buttonSymbol.bbox.xy = [width, height]

export class VisualizerButton extends BasicComponent
    define: =>
        buttonSymbol
