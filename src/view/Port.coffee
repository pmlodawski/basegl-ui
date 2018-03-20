import * as basegl  from 'basegl'
import * as Color   from 'basegl/display/Color'
import {group}      from 'basegl/display/Symbol'
import {Composable} from 'basegl/object/Property'

import * as shape       from 'shape/Port'
import * as nodeShape   from 'shape/Node'
import {Component} from 'view/Component'

inPortShape = basegl.symbol shape.inPortShape
inPortShape.bbox.xy = [shape.width,shape.length]
inPortShape.variables.color_r = 1
inPortShape.variables.color_g = 0
inPortShape.variables.color_b = 0

export class InPort extends Component
    updateModel: ({ key:   @key   = @key
                  , angle: @angle = @angle
                  , position: position = @position or [0,0]
                  , radius: @radius = @radius or 0
                  , color: @color = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        unless @def?
            @def = inPortShape

    updateView: =>
        @group.position.xy = @position
        @view.position.xy = [-shape.width/2, @radius]
        @view.variables.color_r = @color[0]
        @view.variables.color_g = @color[1]
        @view.variables.color_b = @color[2]
        @view.rotation.z = @angle

    registerEvents: =>


outPortShape = basegl.symbol shape.outPortShape
outPortShape.bbox.xy = [shape.width,shape.length]
outPortShape.variables.color_r = 1
outPortShape.variables.color_g = 0
outPortShape.variables.color_b = 0

export class OutPort extends Component
    updateModel: ({ key:   @key   = @key
                  , angle: @angle = @angle
                  , position: position = @position or [0,0]
                  , radius: @radius = @radius or 0
                  , color: @color = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        unless @def?
            @def = outPortShape

    updateView: =>
        @group.position.xy = @position
        @view.position.xy = [-shape.width/2, @radius]
        @view.rotation.z = @angle
        @view.variables.color_r = @color[0]
        @view.variables.color_g = @color[1]
        @view.variables.color_b = @color[2]

    registerEvents: =>


flatPortShape = basegl.symbol shape.flatPortShape
flatPortShape.bbox.xy = [shape.length, shape.width]
flatPortShape.variables.color_r = 1
flatPortShape.variables.color_g = 0
flatPortShape.variables.color_b = 0

export class FlatPort extends Component
    constructor: (args...) ->
        super(args...)
        @output ?= false

    updateModel: ({ key:      @key      = @key
                  , name:     @name     = @name
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , output:   @output   = @output
                  , color: @color = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        unless @def?
            @def = flatPortShape

    updateView: =>
        x = if @output then @position[0] else @position[0] - shape.length
        @view.position.xy = [x, @position[1] - shape.width/2]
        @view.variables.color_r = @color[0]
        @view.variables.color_g = @color[1]
        @view.variables.color_b = @color[2]
