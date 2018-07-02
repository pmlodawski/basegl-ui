import * as basegl      from 'basegl'
import {circle, rect}   from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

offset = 4
aspect = 1.6

checkboxExpr = basegl.expr ->
    corner = 'bbox.y'/2
    background = rect 'bbox.x', 'bbox.y', corner
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.sliderBgColor
    switcherColor = color.sliderColor.mix color.activeGreen, 'checked'
    switcher = circle corner - offset
        .move corner + ('bbox.x' - 2*corner) * 'checked', corner
        .fill switcherColor
    background + switcher

checkboxSymbol = basegl.symbol checkboxExpr
checkboxSymbol.defaultZIndex = layers.slider
checkboxSymbol.bbox.xy = [100, 20]
checkboxSymbol.variables.checked = 0


export class CheckboxShape extends BasicComponent
    initModel: =>
        checked     : false
        width       : null
        height      : null

    define: => checkboxSymbol

    adjust: (view) =>
        if @changed.checked then @__element.variables.checked = Number @model.checked
        if @changed.width or @changed.height
            @__element.bbox.xy = [@model.width, @model.height]
