import * as basegl      from 'basegl'
import {circle, rect}   from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'


offset = 4
aspect = 1.6

checkboxExpr = (style) -> basegl.expr ->
    corner = 'bbox.y'/2
    background = rect 'bbox.x', 'bbox.y', corner
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.sliderBgColor(style)
    switcherColor = color.sliderColor(style).mix color.activeGreen(style), 'checked'
    switcher = circle corner - offset
        .move corner + ('bbox.x' - 2*corner) * 'checked', corner
        .fill switcherColor
    background + switcher

checkboxSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol checkboxExpr (style)
    symbol.defaultZIndex = layers.slider
    symbol.bbox.xy = [100, 20]
    symbol.variables.checked = 0
    symbol

export class CheckboxShape extends BasicComponent
    initModel: =>
        checked: false
        width:   null
        height:  null

    define: => checkboxSymbol @style

    adjust: (view, element) =>
        if @changed.checked
            @animateVariable 'checked', @model.checked
        if @changed.width or @changed.height
            @getElement().bbox.xy = [@model.width, @model.height]
