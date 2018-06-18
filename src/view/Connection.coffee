import * as basegl    from 'basegl'
import {Composable}   from "basegl/object/Property"

import * as shape       from 'shape/Connection'
import * as nodeShape   from 'shape/Node'
import * as portShape   from 'shape/Port'
import * as layers      from 'view/layers'
import {Component}      from 'view/Component'
import {InputNode}      from 'view/InputNode'
import {OutputNode}     from 'view/OutputNode'
import {BasicComponent} from 'view/BasicComponent'
import {ContainerComponent} from 'view/ContainerComponent'


connectionShape = basegl.symbol shape.connectionShape
connectionShape.defaultZIndex = layers.connection
connectionShape.bbox.y = shape.width
connectionShape.variables.color_r = 1
connectionShape.variables.color_g = 0
connectionShape.variables.color_b = 0

class PartialConnection extends BasicComponent
    initModel: =>
        offset: 0
        length: 0
        angle: 0
        color: [1,0,0]
        src: true

    define: =>
        connectionShape

    adjust: (element, view) =>
        if @changed.length
            element.bbox.x = @model.length
        if @changed.offset
            element.position.x = @model.offset
        element.position.y = -shape.width/2
        if @changed.angle
            element.rotation.z = @model.angle
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (element) =>
        element.addEventListener 'mousedown', => @pushEvent
            tag: 'DisconnectEvent'
            src: @model.src

export class Connection extends ContainerComponent
    initModel: =>
        key: null
        srcNode: null
        srcPort: null
        dstNode: null
        dstPort: null

    prepare: =>
        @addDef 'src', new PartialConnection src: true, @parent
        @addDef 'dst', new PartialConnection src: false, @parent

    update: =>

    connectSources: =>
        srcNode = @parent.node @model.srcNode
        dstNode = @parent.node @model.dstNode
        srcPort = srcNode.outPorts[@model.srcPort]
        dstPort = dstNode.inPorts[@model.dstPort]
        @__onColorChange srcPort.color
        @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @addDisposableListener srcPort, 'color', (color) => @__onColorChange color
        @addDisposableListener srcPort, 'position', => @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @addDisposableListener dstPort, 'position', => @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @onDispose => srcPort.unfollow @key
        @onDispose => dstPort.unfollow @key

    __onPositionChange: (srcNode, dstNode, srcPort, dstPort) =>
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
        rotation = Math.atan2 y, x

        @def('src').set
            offset: leftOffset
            length: length/2
            angle: rotation
        @def('dst').set
            offset: leftOffset + length/2
            length: length/2
            angle: rotation
        @view('src').position.xy = srcPos.slice()
        @view('dst').position.xy = srcPos.slice()
        srcPort.follow @key, rotation - Math.PI/2
        dstPort.follow @key, rotation + Math.PI/2

    __onColorChange: (color) =>
        @def('src').set color: color
        @def('dst').set color: color
