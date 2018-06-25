import * as shape       from 'shape/port/Base'

import {FlatPortShape}      from 'shape/port/Flat'
import {TextShape}          from 'shape/Text'
import {Port}               from 'view/port/Base'


export class FlatPort extends Port
    initModel: =>
        key: null
        name: null
        position: [0, 0]
        radius: 0
        output: null
        color: [1,0,0]

    prepare: =>
        @addDef 'port', new FlatPortShape null, @
        @addDef 'name', new TextShape
                align: 'left'
                text: @model.name
            , @

    update: =>
        if @changed.color
            @updateDef 'port',
                color: @model.color
        if @changed.output
            @updateDef 'name', align: if @model.output then 'right' else 'left'

    adjust: (view) =>
        if @changed.output or @changed.position
            x = if @model.output then @model.position[0] - shape.length else @model.position[0]
            view.position.xy = [x, @model.position[1]]
        if @changed.output
            @view('name').position.x = if @model.output then -shape.length else  2* shape.length

    connectionPosition: =>
        [ @model.position[0] + @parent.model.position[0] + (if @model.output then -shape.length else shape.length)
        , @model.position[1] + @parent.model.position[1]
        ]
