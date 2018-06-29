import * as basegl      from 'basegl'
import {rect}           from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'


sliderExpr = basegl.expr ->
    topLeft     = 'bbox.y'/2 * 'topLeft'
    topRight    = 'bbox.y'/2 * 'topRight'
    bottomLeft  = 'bbox.y'/2 * 'bottomLeft'
    bottomRight = 'bbox.y'/2 * 'bottomRight'
    valueWidth  = 'bbox.x' * 'level'
    background = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
    background = background.move 'bbox.x'/2, 'bbox.y'/2
    background = background.fill color.sliderBgColor
    slider = rect valueWidth, 'bbox.y', topLeft, 0, bottomLeft, 0
    slider = slider.move valueWidth/2, 'bbox.y'/2
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
        if @changed.level       then @__element.variables.level       = Number @model.level
        if @changed.topLeft     then @__element.variables.topLeft     = Number @model.topLeft
        if @changed.topRight    then @__element.variables.topRight    = Number @model.topRight
        if @changed.bottomLeft  then @__element.variables.bottomLeft  = Number @model.bottomLeft
        if @changed.bottomRight then @__element.variables.bottomRight = Number @model.bottomRight
        if @changed.width or @changed.height
            @__element.bbox.xy = [@model.width, @model.height]
