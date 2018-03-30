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

export class Connection extends Component
    constructor: (values, parent) ->
        super values, parent
        @srcNodeSubscirbed = false
        @dstNodeSubscribed = false
        @disposables = []

    updateModel: ({ key: @key = @key
                  , srcNode: @srcNode = @srcNode
                  , srcPort: @srcPort = @srcPort
                  , dstNode: @dstNode = @dstNode
                  , dstPort: @dstPort = @dstPort
                  }) =>
        unless @def?
            @def = connectionShape

    updateView: =>
        @connectSources()
        srcNode = @parent.node @srcNode
        dstNode = @parent.node @dstNode
        srcPort = srcNode.outPorts[@srcPort]
        dstPort = dstNode.inPorts[@dstPort]
        srcPos = srcPort.position
        dstPos = dstPort.position
        if srcNode instanceof InputNode
            leftOffset = srcPort.radius
        else
            leftOffset = srcPort.radius + 1/2*portShape.length
        rightOffset = dstPort.radius

        x = dstPos[0] - srcPos[0]
        y = dstPos[1] - srcPos[1]
        length = Math.sqrt(x*x + y*y) - leftOffset - rightOffset
        @view.position.x = leftOffset
        @view.position.y = -shape.width/2
        @view.bbox.x = length
        @group.position.xy = srcPos.slice()
        rotation = Math.atan2 y, x
        @view.rotation.z = rotation
        srcPort?.set follow: rotation - Math.PI/2
        dstPort?.set follow: rotation + Math.PI/2

        @view.variables.color_r = srcPort.color[0]
        @view.variables.color_g = srcPort.color[1]
        @view.variables.color_b = srcPort.color[2]

    connectSources: =>
        unless @srcConnected?
            srcNode = @parent.node @srcNode
            if srcNode?
                srcPort = srcNode.outPorts[@srcPort]
                @addDisposableListener srcPort, 'position', => @updateView()
                @onDispose => srcPort.set follow: null
                @srcConnected = true
        unless @dstConnected
            dstNode = @parent.node @dstNode
            if dstNode?
                dstPort = dstNode.inPorts[@dstPort]
                @addDisposableListener dstPort, 'position', => @updateView()
                @onDispose => dstPort.set follow: null
                @dstConnected = true

    registerEvents: =>
