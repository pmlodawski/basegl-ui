import * as basegl from 'basegl'
import {rect}      from 'basegl/display/Shape'

import * as layers                      from 'view/layers'
import {nodeBg}                         from 'shape/Color'
import * as baseNode                    from 'shape/node/Base'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'


backgroundExpr = (style) -> basegl.expr ->
    bodyHeight   = 'bbox.y' - 2 * style.node_shadowRadius
    bodyWidth    = 'bbox.x' - 2 * style.node_shadowRadius
    windowHeight = 'windowHeight'
    windowWidth  = 'windowWidth'
    radiusTop = style.node_radius * 'roundTop'
    radiusBottom = style.node_radius * 'roundBottom'
    base = rect bodyWidth, bodyHeight, radiusTop, radiusTop, radiusBottom, radiusBottom
    windowRadius = (bodyHeight-windowHeight + bodyWidth-windowWidth)/2
    transparentWindow = rect windowWidth, windowHeight, windowRadius
    background = (base - transparentWindow)
        .fill nodeBg style
    shadow = baseNode.shadowExpr base, style
    (shadow + background)
        .move('bbox.x'/2, 'bbox.y'/2)


backgroundSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol backgroundExpr style
    symbol.defaultZIndex = layers.expandedNode
    symbol.variables.windowHeight = 0
    symbol.variables.windowWidth = 0
    symbol.variables.roundTop = 0
    symbol.variables.roundBottom = 0
    symbol

export class BackgroundShape extends BasicComponent
    initModel: =>
        width: 100
        height: 100
        offsetH: null
        offsetV: null
        roundTop: null
        roundBottom: null
    define: => backgroundSymbol @style
    adjust: (element) =>
        if @changed.width
            element.position.x = - @style.node_shadowRadius
            element.bbox.x = @model.width + 2 * @style.node_shadowRadius
        if @changed.height
            element.position.y = - @model.height - @style.node_shadowRadius
            element.bbox.y = @model.height + 2 * @style.node_shadowRadius
        if @changed.offsetV
            windowHeight = @model.height - 2 * @model.offsetV if @model.offsetV?
            element.variables.windowHeight = windowHeight or 0
        if @changed.offsetH
            windowWidth = @model.width - 2 * @model.offsetH if @model.offsetH?
            element.variables.windowWidth = windowWidth or 0
        if @changed.roundBottom
            @animateVariable 'roundBottom', Number not @model.roundBottom
        if @changed.roundTop
            @animateVariable 'roundTop', Number not @model.roundTop