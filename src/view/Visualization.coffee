import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort, OutPort} from 'view/Port'
import {Component}       from 'view/Component'
import * as shape        from 'shape/Visualization'
import * as util         from 'shape/util'
import * as nodeShape    from 'shape/Node'
import {Widget}   from 'view/Widget'

visualizationShape = basegl.symbol shape.visualizationShape

export class Visualization extends Widget
    constructor: (args...) ->
        super args...
        @configure
            height: 300
            width:  200

    updateModel: ({ nodeKey:            @nodeKey            = @nodeKey
                  , key:                @key                = @key
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , selectedVisualizer:  selectedVisualizer = @selectedVisualizer
                  , visualizers:         visualizers        = @visualizers}) =>
        if @mode != mode or @currentVisualizer != currentVisualizer or @selectedVisualizer != selectedVisualizer or @visualizers != visualizers
            @mode               = mode
            @currentVisualizer  = currentVisualizer
            @selectedVisualizer = selectedVisualizer
            @visualizers        = visualizers
            @def =
                [ { name: 'visualization', def: visualizationShape }
                ]
            if @view?
                @reattach

    updateView: =>
        node = @parent.node @nodeKey
        offset = if node.expanded
                [ - nodeShape.width/2
                , - node.bodyHeight - nodeShape.height/2 - nodeShape.slope ]
            else [ 0, - nodeShape.height / 2 ]    
        @group.position.xy =
            [ node.position[0] + offset[0] - @width/2
            , node.position[1] + offset[1]]

    registerEvents: =>
        node = @parent.node @nodeKey
        @addDisposableListener node, 'position', => @updateView()
