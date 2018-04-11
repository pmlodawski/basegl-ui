import {Component} from 'view/Component'
import * as shape  from 'shape/Port'
import * as basegl from 'basegl'
import {FlatPort}  from 'view/Port'


height = 100
windowLength = 1000

export class OutputNode extends Component
    updateModel: ({ key:      @key      = @key
                  , inPorts:  inPorts   = @inPorts
                  , position: @position  = @position or [0,0]
                  }) =>
        @setInPorts inPorts

        i = 0
        keys = Object.keys @inPorts
        portOffset = height / keys.length
        for key in keys
            inPort = @inPorts[key]
            inPort.set position: [@position[0] - shape.length, @position[1] + i * portOffset]
            i++

    setInPorts: (inPorts) =>
        @inPorts ?= {}
        if inPorts.length?
            for inPort in inPorts
                @setInPort inPort
        else
            for inPortKey in Object.keys inPorts
                @setInPort inPorts[inPortKey]

    setInPort: (inPort) =>
        if @inPorts[inPort.key]?
            @inPorts[inPort.key].set inPort
        else
            inPort.output = true
            portView = new FlatPort inPort, @
            @inPorts[inPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    align: (x, y) =>
        unless x == @position[0] and y == @position[1]
            @set position: [x, y]

    registerEvents: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                campos = scene.camera.position
                x = scene.width/2 + campos.x + scene.width/2*campos.z
                y = scene.height/2 + campos.y - height/2
                @align x, y
