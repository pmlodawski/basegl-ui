import * as basegl       from 'basegl'
import {triangle}        from 'basegl/display/Shape'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as layers       from 'view/layers'
import {valueTogglerColor}    from 'shape/Color'
import * as baseNode     from 'shape/node/Base'


export size = 10 

valueTogglerExpr = basegl.expr ->
    isFolded = 'isFolded'
    triangle(size, size)
        .fill valueTogglerColor
        .rotate(isFolded * Math.PI)
        .moveX size/2
        .moveY(isFolded * size)

valueTogglerSymbol         = basegl.symbol valueTogglerExpr
valueTogglerSymbol.defaultZIndex = layers.valueToggler
valueTogglerSymbol.bbox.xy = [size, size]
valueTogglerSymbol.variables.isFolded = 0

export class ValueTogglerShape extends BasicComponent
    initModel: =>
        body: [100, 100]
        isFolded: false
        expanded: false
    define: => valueTogglerSymbol
    adjust: (element, view) =>
        if @changed.isFolded
            element.variables.isFolded = Number not @model.isFolded
        element.position.xy = [- size/2, - size/2]

        view.position.xy =
            if @model.expanded
                [- baseNode.width/2, -@model.body[1] - baseNode.height/2 - baseNode.slope]
            else
                [- baseNode.width/2, - baseNode.height/2]
