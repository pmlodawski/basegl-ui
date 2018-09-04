import * as basegl       from 'basegl'
import {halfplane, rect} from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}  from 'abstract/BasicComponent'
import * as color        from 'shape/Color'
import * as layers       from 'view/layers'


sliderExpr = (styles) -> basegl.expr ->
    topLeft     = 'bbox.y'/2 * 'topLeft'
    topRight    = 'bbox.y'/2 * 'topRight'
    bottomLeft  = 'bbox.y'/2 * 'bottomLeft'
    bottomRight = 'bbox.y'/2 * 'bottomRight'
    valueWidth  = 'bbox.x' * 'level'
    background = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.sliderBgColor(styles)
    slider = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
        .move 'bbox.x'/2, 'bbox.y'/2
    cutter = halfplane -Math.PI/2, true
        .move valueWidth, 0
    slider = slider - cutter
    slider = slider.fill color.sliderColor(styles)
    background + slider

sliderSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol sliderExpr styles
    symbol.defaultZIndex = layers.slider
    symbol.bbox.xy = [100, 20]
    symbol.variables.level = 0
    symbol.variables.topLeft     = 0
    symbol.variables.topRight    = 0
    symbol.variables.bottomLeft  = 0
    symbol.variables.bottomRight = 0
    symbol

export class SliderShape extends BasicComponent
    initModel: =>
        level       : null
        topLeft     : null
        topRight    : null
        bottomLeft  : null
        bottomRight : null
        width       : null
        height      : null

    define: => sliderSymbol @styles

    adjust: (view) =>
        vars = @getElement().variables
        if @changed.level       then vars.level       = Number @model.level
        if @changed.topLeft     then vars.topLeft     = Number @model.topLeft
        if @changed.topRight    then vars.topRight    = Number @model.topRight
        if @changed.bottomLeft  then vars.bottomLeft  = Number @model.bottomLeft
        if @changed.bottomRight then vars.bottomRight = Number @model.bottomRight
        if @changed.width or @changed.height
            @getElement().bbox.xy = [@model.width, @model.height]

    registerEvents: =>
        @watchStyles 'baseColor_r', 'baseColor_g', 'baseColor_b', 'bgColor_h', 'bgColor_s', 'bgColor_l'
