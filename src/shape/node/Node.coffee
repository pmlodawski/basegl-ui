import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path
    , plane, triangle} from 'basegl/display/Shape'
import {vector}        from 'basegl/math/Vector'
import {nodeBg, selectionColor} from 'shape/Color'
import {BasicComponent, memoizedSymbol}  from 'abstract/BasicComponent'
import * as layers       from 'view/layers'
import * as baseNode         from 'shape/node/Base'

#### shapes with frames and selections ####

compactNodeExpr = (styles) -> basegl.expr ->
    node = baseNode.compactNodeExpr()
    node   = node.fill nodeBg styles

    eye    = 'scaledEye.z'
    border = node.grow(Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.7)).grow(-1)

    sc     = selectionColor styles
    sc.a   = 'selected'
    border = border.fill sc

    border + node

compactNodeSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol compactNodeExpr styles
    symbol.defaultZIndex = layers.compactNode
    symbol.variables.selected = 0
    symbol.bbox.xy = [baseNode.width, baseNode.height]
    symbol

expandedNodeExpr = (styles) -> basegl.expr ->
    node   = baseNode.expandedNodeExpr()
    node   = node.fill nodeBg styles

    eye    = 'scaledEye.z'
    border = node.grow(Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.7)).grow(-1)

    sc     = selectionColor styles
    sc.a   = 'selected'
    border = border.fill sc

    border + node

expandedNodeSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol expandedNodeExpr styles
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
            expandedNodeSymbol @styles
        else
            compactNodeSymbol @styles
    adjust: (element) =>
        if @model.expanded
            element.position.xy = [-baseNode.width/2, -@model.body[1] - baseNode.height/2 - baseNode.slope]
            element.variables.bodyWidth  = @model.body[0]
            element.variables.bodyHeight = @model.body[1]
        else
            element.position.xy = [-baseNode.width/2, -baseNode.height/2]
        element.variables.selected = if @model.selected then 1 else 0
        if @changed.selected
            applySelectAnimation element, not @model.selected

    registerEvents: =>
        @watchStyles 'baseColor_r', 'baseColor_g', 'baseColor_b', 'node_selection_h', 'node_selection_s', 'node_selection_l', 'node_selection_a'
