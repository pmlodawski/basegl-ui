import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Color       from 'basegl/display/Color'
import {pie, rect}      from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'
import {PortShape}      from 'shape/port/Base'

angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle

bboxHeight = width*2
bboxWidth = length*5
overlap = 1

export flatPortExpr = (styles) -> basegl.expr ->
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    cutterWidth = 'bbox.x' - length
    cutter = rect cutterWidth + overlap, 'bbox.y' + overlap
        .move (1-'is_output')*length + cutterWidth/2, 'bbox.y'/2
        # .fill color.activeArea
    port = pie -angle
        .rotate -Math.PI /2
        .move (bboxWidth*'is_output' + length*(1-'is_output')), bboxHeight/2
    port = port - cutter
    port = port.fill color.varHover styles
    activeArea + port

flatPortSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol flatPortExpr styles
    symbol.bbox.xy = [bboxWidth, bboxHeight]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.variables.is_output = 0
    symbol.defaultZIndex = layers.flatPort
    symbol

export class FlatPortShape extends PortShape
    initModel: =>
        model = super()
        model.output = null
        model
    define: => flatPortSymbol @styles
    adjust: (element) =>
        super element
        if @changed.output
            x = if @model.output then (- bboxWidth) else 0
            element.variables.is_output = Number @model.output
            element.position.xy = [x, -bboxHeight/2]
    registerEvents: (view) =>
        super view
        @watchStyles 'baseColor_r', 'baseColor_g', 'baseColor_b'
