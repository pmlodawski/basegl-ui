import * as basegl from 'basegl'
import {rect}      from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers                      from 'view/layers'
import * as baseNode                    from 'shape/node/Base'
import {nodeBg}                         from 'shape/Color'

backgroundExpr = (style) -> basegl.expr ->
    bodyHeight   = 'bbox.y'
    bodyWidth    = 'bbox.x'
    windowHeight = 'windowHeight'
    windowWidth  = 'windowWidth'
    base = rect bodyWidth, bodyHeight, style.node_radius
    windowRadius = (bodyHeight-windowHeight + bodyWidth-windowWidth)/2
    transparentWindow = rect windowWidth, windowHeight, windowRadius
    background = (base - transparentWindow)
        .fill nodeBg style
    shadow = baseNode.shadowExpr base, style
    (shadow + background)
        .move(bodyWidth/2, bodyHeight/2)


backgroundSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol backgroundExpr style
    symbol.defaultZIndex = layers.expandedNode
    symbol.variables.windowHeight = 0
    symbol.variables.windowWidth = 0
    symbol


export class BackgroundShape extends BasicComponent
    initModel: =>
        width: 100
        height: 100
        offsetH: null
        offsetV: null
    define: => backgroundSymbol @style
    adjust: (element) =>
        if @changed.width
            element.bbox.x = @model.width
        if @changed.height
            element.position.y = - @model.height
            element.bbox.y = @model.height
        if @changed.offsetV
            windowHeight = @model.height - 2 * @model.offsetV if @model.offsetV?
            element.variables.windowHeight = windowHeight or 0
        if @changed.offsetH
            windowWidth = @model.width - 2 * @model.offsetH if @model.offsetH?
            element.variables.windowWidth = windowWidth or 0
