import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie, rect}  from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/node/Base'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as layers       from 'view/layers'

addPortRadius = length
export addPortWidth = 2 * addPortRadius
export addPortHeight = 2 * addPortRadius
plusLength = addPortWidth / 2
plusThickness = plusLength/4

export addPortExpr = basegl.expr ->
    c = circle addPortRadius
       .move addPortRadius, addPortRadius
    horizontal = rect plusLength, plusThickness
                .move addPortRadius, addPortRadius
    vertical = rect plusThickness, plusLength
              .move addPortRadius, addPortRadius
    plus = horizontal + vertical
    port = c - plus
    port.fill Color.rgb [0.2, 0.2, 0.2]

addPortSymbol = basegl.symbol addPortExpr
addPortSymbol.bbox.xy = [addPortWidth, addPortHeight]

export class AddPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => addPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-addPortWidth/2, -addPortHeight/2]
