import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing                      from 'basegl/animation/Easing'
import {nodeBg, selectionColor}         from 'shape/Color'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers                      from 'view/layers'
import * as baseNode                    from 'shape/node/Base'


compactNodeExpr = (style) -> basegl.expr ->
    base = baseNode.compactNodeExpr style
    node = base.fill nodeBg style
    shadow = baseNode.shadowExpr base, style
    eye  = 'scaledEye.z'
    sc   = selectionColor style
    sc.a = 'selected'
    selection = base.grow(Math.pow(Math.clamp(eye*style.node_selection_size, 0.0, 400.0),0.7)).grow(-1)
        .fill sc
    shadow + selection + node

compactNodeSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol compactNodeExpr style
    symbol.defaultZIndex = layers.compactNode
    symbol.variables.selected = 0
    symbol.bbox.xy = [baseNode.width(style), baseNode.height(style)]
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
        selected: false
    define: => compactNodeSymbol @style
    adjust: (element) =>
        element.position.xy = [-baseNode.width(@style)/2, -baseNode.height(@style)/2]
        element.variables.selected = if @model.selected then 1 else 0
        if @changed.selected
            applySelectAnimation element, not @model.selected
