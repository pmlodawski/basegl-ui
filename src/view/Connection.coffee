import {ConnectionShape}    from 'shape/Connection'
import {ContainerComponent} from 'abstract/ContainerComponent'


export class Connection extends ContainerComponent
    initModel: =>
        key: null
        srcNode: null
        srcPort: null
        dstNode: null
        dstPort: null

    prepare: =>
        @addDef 'src', new ConnectionShape src: true, @parent
        @addDef 'dst', new ConnectionShape src: false, @parent

    update: =>

    registerEvents: (view) =>
        registerDisconnect = (target, src) => @view(target).addEventListener 'mousedown', => @pushEvent
            tag: 'DisconnectEvent'
            src: src
        registerDisconnect 'src', true
        registerDisconnect 'dst', false

    connectSources: =>
        srcNode = @parent.node @model.srcNode
        dstNode = @parent.node @model.dstNode
        srcPort = srcNode.outPort @model.srcPort
        dstPort = dstNode.inPort @model.dstPort
        @__onColorChange srcPort
        @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @addDisposableListener srcPort, 'color', (color) => @__onColorChange srcPort
        @addDisposableListener srcNode, 'position', => @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @addDisposableListener dstNode, 'position', => @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @addDisposableListener dstPort, 'position', => @__onPositionChange srcNode, dstNode, srcPort, dstPort
        @onDispose => srcPort.unfollow @model.key
        @onDispose => dstPort.unfollow @model.key

    __onPositionChange: (srcNode, dstNode, srcPort, dstPort) =>
        srcPos = srcPort.connectionPosition()
        dstPos = dstPort.connectionPosition()
        leftOffset = srcPort.model.radius
        rightOffset = dstPort.model.radius

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
        srcPort.follow @model.key, rotation - Math.PI/2
        dstPort.follow @model.key, rotation + Math.PI/2

    __onColorChange: (srcPort) =>
        @def('src').set color: srcPort.model.color
        @def('dst').set color: srcPort.model.color
