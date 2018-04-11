import {Component} from 'view/Component'
import * as shape  from 'shape/Port'
import * as basegl from 'basegl'
import {FlatPort}  from 'view/Port'


height = 100

export class InputNode extends Component
    updateModel: ({ key:      @key      = @key
                  , outPorts: outPorts = @outPorts
                  , position: position = @position or [0,0]
                  }) =>
        @emitProperty 'position', position
        @setOutPorts outPorts

        i = 0
        keys = Object.keys @outPorts
        portOffset = height / keys.length
        for key in keys
            outPort = @outPorts[key]
            outPort.set position: [@position[0] + shape.length, @position[1] + i * portOffset]
            i++

    setOutPorts: (outPorts) =>
        @outPorts ?= {}
        if outPorts.length?
            for outPort in outPorts
                @setOutPort outPort
        else
            for outPortKey in Object.keys outPorts
                @setOutPort outPorts[outPortKey]

    setOutPort: (outPort) =>
        if @outPorts[outPort.key]?
            @outPorts[outPort.key].set outPort
        else
            portView = new FlatPort outPort, @
            @outPorts[outPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    getPosition: (scene) =>

    align: (x, y) =>
        unless x == @position[0] and y == @position[1]
            @set position: [x, y]

    registerEvents: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                campos = scene.camera.position
                x = scene.width/2 + campos.x - scene.width/2*campos.z
                y = scene.height/2 + campos.y - height/2
                @align x, y
