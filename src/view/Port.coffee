import * as basegl  from 'basegl'
import * as Color   from 'basegl/display/Color'
import {group}      from 'basegl/display/Symbol'
import {Composable} from 'basegl/object/Property'

import * as shape       from 'shape/Port'
import * as nodeShape   from 'shape/Node'
import * as util        from 'shape/util'
import {Component}      from 'view/Component'


inPortShape = basegl.symbol shape.inPortShape
inPortShape.bbox.xy = [shape.width,shape.length]
inPortShape.variables.color_r = 1
inPortShape.variables.color_g = 0
inPortShape.variables.color_b = 0
nameOffset = shape.width

selfPortShape = basegl.symbol shape.selfPortShape
selfPortShape.bbox.xy = [shape.selfPortWidth, shape.selfPortHeight]
selfPortShape.variables.color_r = 1
selfPortShape.variables.color_g = 0
selfPortShape.variables.color_b = 0
nameOffset = shape.width

export class InPort extends Component
    updateModel: ({ key:      @key      = @key
                  , name:      name     = @name
                  , angle:    @angle    = @angle
                  , mode:     @mode     = @mode or 'in'
                  , follow:   @follow   = @follow
                  , locked:   @locked   = @locked or false
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , color:    @color    = @color or [0, 1, 0]
                  , widgets:  @widgets  = @widgets or []
                  }) =>
        @emitProperty 'position', position
        unless @def? and @name == name
            @name = name
            nameDef = util.text str: @name
            if @mode == 'self'
                portShape = selfPortShape
            else
                portShape = inPortShape
            @def = [{ name: 'port', def: portShape }
                   ,{ name: 'name', def: nameDef }
                   ]
            if @view?
                @reattach()

    updateView: =>
        @group.position.xy =
            if @locked
                [@position[0] + shape.length, @position[1]]
            else
                @position
        if @mode == 'self'
            @view.port.position.xy = [-shape.selfPortWidth/2, -shape.selfPortHeight/2]
            @view.port.variables.color_r = @color[0]
            @view.port.variables.color_g = @color[1]
            @view.port.variables.color_b = @color[2]
        else
            @view.port.position.xy = [-shape.width/2, @radius]
            @view.port.variables.color_r = @color[0]
            @view.port.variables.color_g = @color[1]
            @view.port.variables.color_b = @color[2]
            rotation = if @follow? and not @locked then @follow else @angle
            @view.port.rotation.z = rotation
            nameSize = util.textSize @view.name
            @view.name.rotation.z = rotation - Math.PI/2
            @view.name.position.xy = [- nameSize[0] - nameOffset - shape.length - @radius, -nameSize[1]/2]

    registerEvents: =>


outPortShape = basegl.symbol shape.outPortShape
outPortShape.bbox.xy = [shape.width,shape.length]
outPortShape.variables.color_r = 1
outPortShape.variables.color_g = 0
outPortShape.variables.color_b = 0

export class OutPort extends Component
    updateModel: ({ key:   @key   = @key
                  , angle: @angle = @angle
                  , follow: @follow = @follow
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
        rotation = if @follow? then @follow else @angle
        @view.rotation.z = rotation
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
                  , name:      name     = @name
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , output:   @output   = @output
                  , color: @color = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        unless @def? and @name == name
            @name = name
            nameDef = util.text str: @name
            @def = [{ name: 'port', def: flatPortShape }
                   ,{ name: 'name', def: nameDef }
                   ]
            if @view?
                @reattach()

    updateView: =>
        x = if @output then @position[0] else @position[0] - shape.length
        @group.position.xy = [x, @position[1] - shape.width/2]
        nameHeight = util.textHeight @view.name
        @view.name.position.xy = [2* shape.length, nameHeight/2]
        @view.port.variables.color_r = @color[0]
        @view.port.variables.color_g = @color[1]
        @view.port.variables.color_b = @color[2]
