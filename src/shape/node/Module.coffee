import * as basegl from 'basegl'
import {rect}      from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers                      from 'view/layers'
import * as baseNode                    from 'shape/node/Base'
import {nodeBg}                         from 'shape/Color'

moduleExpr = (style) -> basegl.expr ->
    bodyWidth    = 'bbox.x'
    bodyHeight   = 'bbox.y'
    base = rect(bodyWidth, bodyHeight, style.node_radius)
        .move(bodyWidth/2, bodyHeight/2)
    module = base.fill nodeBg style
    shadow = baseNode.shadowExpr base, style
    shadow + module


moduleSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol moduleExpr style
    symbol.defaultZIndex = layers.expandedNode
    symbol.variables.selected = 0
    symbol


export class ModuleShape extends BasicComponent
    initModel: =>
        width: 100
        height: 100
    define: => moduleSymbol @style
    adjust: (element) =>
        if @changed.width
            element.bbox.x = @model.width
        if @changed.height
            element.position.y = - @model.height
            element.bbox.y = @model.height
