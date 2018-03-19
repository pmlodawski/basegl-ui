import * as basegl  from 'basegl'
import {group}      from 'basegl/display/Symbol'
import {Composable} from "basegl/object/Property"

import * as shape       from 'shape/Port'
import * as nodeShape   from 'shape/Node'
import {Component} from 'view/Component'

inPortShape = basegl.symbol shape.inPortShape
inPortShape.bbox.xy = [shape.width,shape.length]


export class InPort extends Component
    updateModel: ({ key:   @key   = @key
                  , angle: @angle = @angle
                  , position: position = @position or [0,0]
                  , radius: @radius = @radius or 0
                  }) =>
        @emitProperty 'position', position
        unless @def?
            @def = inPortShape

    updateView: =>
        @group.position.xy = @position
        @view.position.xy = [-shape.width/2, @radius]
        @view.rotation.z = @angle

    registerEvents: =>


outPortShape = basegl.symbol shape.outPortShape
outPortShape.bbox.xy = [shape.width,shape.length]

export class OutPort extends Component
    updateModel: ({ key:   @key   = @key
                  , angle: @angle = @angle
                  , position: position = @position or [0,0]
                  , radius: @radius = @radius or 0
                  }) =>
        @emitProperty 'position', position
        unless @def?
            @def = outPortShape

    updateView: =>
        @group.position.xy = @position
        @view.position.xy = [-shape.width/2, @radius]
        @view.rotation.z = @angle

    registerEvents: =>


flatPortShape = basegl.symbol shape.flatPortShape
flatPortShape.bbox.xy = [shape.length, shape.width]

export class FlatPort extends Component
    constructor: (args...) ->
        super(args...)
        @output ?= false

    updateModel: ({ key:      @key      = @key
                  , name:     @name     = @name
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , output:   @output   = @output}) =>
        @emitProperty 'position', position
        unless @def?
            @def = flatPortShape

    updateView: =>
        x = if @output then @position[0] else @position[0] - shape.length
        @view.position.xy = [x, @position[1] - shape.width/2]
