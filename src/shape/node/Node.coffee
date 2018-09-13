import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing                      from 'basegl/animation/Easing'
import * as Color                       from 'basegl/display/Color'
import {nodeBg, selectionColor}         from 'shape/Color'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers                      from 'view/layers'
import * as baseNode                    from 'shape/node/Base'


nodeExpr = (baseExpr, style) -> basegl.expr ->
    base = baseExpr style
    node = base.fill nodeBg style
    shadow = base
        .blur style.node_shadowRadius, style.node_shadowPower
        .fill Color.rgb [0, 0, 0, style.node_shadowOpacity]
    eye  = 'scaledEye.z'
    sc   = selectionColor style
    sc.a = 'selected'
    selection = base.grow(Math.pow(Math.clamp(eye*style.node_selection_size, 0.0, 400.0),0.7)).grow(-1)
        .fill sc
    shadow + selection + node

compactNodeExpr = (style) -> nodeExpr baseNode.compactNodeExpr, style

expandedNodeExpr = (style) -> nodeExpr baseNode.expandedNodeExpr, style

compactNodeSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol compactNodeExpr style
    symbol.defaultZIndex = layers.compactNode
    symbol.variables.selected = 0
    symbol.bbox.xy = [baseNode.width(style), baseNode.height(style)]
    symbol

expandedNodeSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol expandedNodeExpr style
    symbol.defaultZIndex = layers.expandedNode
    symbol.variables.selected = 0
    symbol.variables.bodyWidth = 200
    symbol.variables.bodyHeight = 300
    symbol

applySelectAnimation = (symbol, rev=false) ->
    if symbol.selectionAnimation?
    then symbol.selectionAnimation.reverse()
    else
        anim = Animation.create
            easing      : Easing.quadInOut
            duration    : 0.1
            onUpdate    : (v) -> symbol.variables.selected = v
            onCompleted :     -> delete symbol.selectionAnimation
        if rev then anim.inverse()
        anim.start()
        symbol.selectionAnimation = anim
        anim

export class NodeShape extends BasicComponent
    initModel: =>
        expanded: false
        selected: false
        body:     [100, 100]

    redefineRequired: => @changed.expanded
    define: =>
        if @model.expanded
            expandedNodeSymbol @style
        else
            compactNodeSymbol @style
    adjust: (element) =>
        if @model.expanded
            element.position.xy = [-baseNode.width(@style)/2 - @style.node_moveX, -@model.body[1] - baseNode.height(@style)/2 - @style.node_headerOffset]
            element.variables.bodyWidth  = @model.body[0]
            element.variables.bodyHeight = @model.body[1]
        else
            element.position.xy = [-baseNode.width(@style)/2, -baseNode.height(@style)/2]
        element.variables.selected = if @model.selected then 1 else 0
        if @changed.selected
            applySelectAnimation element, not @model.selected
