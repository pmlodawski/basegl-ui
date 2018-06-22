import * as basegl    from 'basegl'
import * as Color     from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import {vector}         from 'basegl/math/Vector'
import {BasicComponent} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import * as baseNode    from 'shape/node/Base'


errorFrame = 20.0
export errorWidth = baseNode.width + errorFrame
export errorHeight = baseNode.height + errorFrame
stripeWidth = 30.0
rotation = Math.PI * 3 / 4
start = errorFrame/3

expandedNodeErrorExpr = basegl.expr ->
    frame = baseNode.expandedNodeExpr().grow 20
           .fill Color.rgb [1,0,0]
    stripe = rect 1000, stripeWidth
            .repeat vector(0, 1), stripeWidth
            .move 0, start
            .rotate rotation
    frame * stripe

expandedNodeErrorSymbol = basegl.symbol expandedNodeErrorExpr
expandedNodeErrorSymbol.defaultZIndex = layers.expandedNodeError
expandedNodeErrorSymbol.variables.selected = 0
expandedNodeErrorSymbol.variables.bodyWidth = 200
expandedNodeErrorSymbol.variables.bodyHeight = 300

compactNodeErrorExpr = basegl.expr ->
    frame = baseNode.compactNodeExpr().grow errorFrame
           .fill Color.rgb [1,0,0]
    stripe = rect 1000, stripeWidth
            .repeat vector(0, 1), stripeWidth
            .move 0, start
            .rotate rotation
    frame * stripe

compactNodeErrorSymbol = basegl.symbol compactNodeErrorExpr
compactNodeErrorSymbol.defaultZIndex = layers.compactNodeError
compactNodeErrorSymbol.variables.selected = 0
compactNodeErrorSymbol.bbox.xy = [errorWidth, errorHeight]

export class NodeErrorShape extends BasicComponent
    initModel: =>
        expanded: false
        body:     [100, 100]
    redefineRequired: => @changed.expanded
    define: =>
        if @model.expanded
            expandedNodeErrorSymbol
        else
            compactNodeErrorSymbol

    adjust: (element) =>
        if @model.expanded
            element.variables.bodyWidth  = @model.body[0]
            element.variables.bodyHeight = @model.body[1]
            element.position.xy = [-baseNode.width/2, -@model.body[1] - baseNode.height/2 - baseNode.slope]
        else
            element.position.xy = [-baseNode.width/2, -baseNode.height/2]
