import * as basegl from 'basegl'
import {rect}      from 'basegl/display/Shape'

import * as layers                      from 'view/layers'
import {nodeBg}                         from 'shape/Color'
import * as baseNode                    from 'shape/node/Base'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'


backgroundExpr = (style) -> basegl.expr ->
    bodyHeight   = 'bbox.y' - 2 * style.node_shadowRadius
    bodyWidth    = 'bbox.x' - 2 * style.node_shadowRadius
    radiusTop = style.node_radius * 'roundTop'
    radiusBottom = style.node_radius * 'roundBottom'
    base = rect bodyWidth, bodyHeight, radiusTop, radiusTop, radiusBottom, radiusBottom
    background = base.fill nodeBg style
        .moveX 'invisible' * 'bbox.x'
    shadow = baseNode.shadowExpr base, style
    (shadow + background)
        .move('bbox.x'/2, 'bbox.y'/2)


backgroundSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol backgroundExpr style
    symbol.defaultZIndex = layers.expandedNode
    symbol.variables.invisible = 0
    symbol.variables.roundTop = 0
    symbol.variables.roundBottom = 0
    symbol

export class BackgroundShape extends BasicComponent
    initModel: =>
        width: 100
        height: 100
        invisible: false
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
        if @changed.invisible
            element.variables.invisible = Number @model.invisible
        if @changed.roundBottom
            @animateVariable 'roundBottom', Number @model.roundBottom
        if @changed.roundTop
            @animateVariable 'roundTop', Number @model.roundTop
