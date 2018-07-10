import * as basegl       from 'basegl'
import {halfplane, rect} from 'basegl/display/Shape'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as color        from 'shape/Color'
import * as layers       from 'view/layers'


sliderExpr = basegl.expr ->
    topLeft     = 'bbox.y'/2 * 'topLeft'
    topRight    = 'bbox.y'/2 * 'topRight'
    bottomLeft  = 'bbox.y'/2 * 'bottomLeft'
    bottomRight = 'bbox.y'/2 * 'bottomRight'
    valueWidth  = 'bbox.x' * 'level'
    background = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.sliderBgColor
    slider = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
        .move 'bbox.x'/2, 'bbox.y'/2
    cutter = halfplane -Math.PI/2, true
        .move valueWidth, 0
    slider = slider - cutter
    slider = slider.fill color.sliderColor
    background + slider

sliderSymbol = basegl.symbol sliderExpr
sliderSymbol.defaultZIndex = layers.slider
sliderSymbol.bbox.xy = [100, 20]
sliderSymbol.variables.level = 0
sliderSymbol.variables.topLeft     = 0
sliderSymbol.variables.topRight    = 0
sliderSymbol.variables.bottomLeft  = 0
sliderSymbol.variables.bottomRight = 0


export class SliderShape extends BasicComponent
    initModel: =>
        level       : null
        topLeft     : null
        topRight    : null
        bottomLeft  : null
        bottomRight : null
        width       : null
        height      : null

    define: => sliderSymbol

    adjust: (view) =>
        vars = @getElement().variables
        if @changed.level       then vars.level       = Number @model.level
        if @changed.topLeft     then vars.topLeft     = Number @model.topLeft
        if @changed.topRight    then vars.topRight    = Number @model.topRight
        if @changed.bottomLeft  then vars.bottomLeft  = Number @model.bottomLeft
        if @changed.bottomRight then vars.bottomRight = Number @model.bottomRight
        if @changed.width or @changed.height
            @getElement().bbox.xy = [@model.width, @model.height]
