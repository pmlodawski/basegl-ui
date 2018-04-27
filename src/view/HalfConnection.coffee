import * as basegl    from 'basegl'
import {group}        from 'basegl/display/Symbol'
import {Composable}   from "basegl/object/Property"

import * as shape       from 'shape/Connection'
import * as nodeShape   from 'shape/Node'
import * as portShape   from 'shape/Port'
import {Component}  from 'view/Component'
import {InputNode}  from 'view/InputNode'
import {OutputNode} from 'view/OutputNode'


connectionShape = basegl.symbol shape.connectionShape
connectionShape.bbox.y = shape.width
connectionShape.variables.color_r = 1
connectionShape.variables.color_g = 0
connectionShape.variables.color_b = 0

export class HalfConnection extends Component
    constructor: (args...) ->
        super args...
        @srcNodeSubscirbed = false

    updateModel: ({ srcNode:  @srcNode  = @srcNode
                  , srcPort:  @srcPort  = @srcPort
                  , dstPos:   @dstPos   = @dstPos
                  , reversed: @reversed = @reversed or false
                  }) =>
        unless @def?
            @def = connectionShape

        return unless @parent?
        @srcNode2 = @parent.node @srcNode
        return unless @srcNode2?
        @srcPort2 =
            if @reversed
                @srcNode2.outPorts[@srcPort]
            else
                @srcNode2.inPorts[@srcPort]

    updateView: =>
        return unless @srcPort2? and @dstPos?
        srcPos = @srcPort2.position
        if @srcNode2 instanceof InputNode
            leftOffset = @srcPort2.radius
        else
            leftOffset = @srcPort2.radius + 1/2*portShape.length
        rightOffset = 0

        x = @dstPos[0] - srcPos[0]
        y = @dstPos[1] - srcPos[1]
        length = Math.sqrt(x*x + y*y) - leftOffset - rightOffset
        @view.position.x = leftOffset
        @view.position.y = -shape.width/2
        @view.bbox.x = length
        @group.position.xy = srcPos.slice()
        rotation = Math.atan2 y, x
        @view.rotation.z = rotation
        @srcPort2.set follow: rotation - Math.PI/2

        @view.variables.color_r = @srcPort2.color[0]
        @view.variables.color_g = @srcPort2.color[1]
        @view.variables.color_b = @srcPort2.color[2]

    registerEvents: =>
        unless @srcConnected?
            if @srcPort2?
                @addDisposableListener @srcPort2, 'position', => @updateView()
                @onDispose => @srcPort2.set follow: null
                @srcConnected = true
        unless @dstConnected
            @withScene (scene) =>
                @addDisposableListener window, 'mousemove', (e) =>
                    campos = scene.camera.position
                    y = scene.height/2 + campos.y + (-scene.screenMouse.y + scene.height/2) * campos.z
                    x = scene.width/2  + campos.x + (scene.screenMouse.x - scene.width/2) * campos.z
                    @set dstPos: [x, y]
                @dstConnected = true
