import * as shape       from 'shape/port/Base'

import {FlatPortShape}      from 'shape/port/Flat'
import {FramedText}         from 'widget/FramedText'
import {Port, defaultColor} from 'view/port/Base'


export class FlatPort extends Port
    initModel: =>
        key: null
        name: null
        position: [0, 0]
        radius: 0
        output: null
        color: defaultColor

    prepare: =>
        @addDef 'port', FlatPortShape, output: @model.output
        @addDef 'name', FramedText,
            align: 'left'
            text: @model.name
            color: [@style.text_color_r, @style.text_color_g, @style.text_color_b]

    update: =>
        if @changed.color
            @updateDef 'port',
                color: @model.color
        if @changed.output
            @updateDef 'name', align: if @model.output then 'right' else 'left'
            @updateDef 'port',
                output: @model.output

    adjust: (view) =>
        if @changed.output or @changed.position
            view.position.xy = @model.position.slice()
        if @changed.output
            @view('name').position.x = if @model.output then -@style.port_length else  2* @style.port_length

    connectionPosition: =>
        [ @model.position[0] + @parent.parent.model.position[0] + (if @model.output then -shape.offset(@style) else shape.offset(@style))
        , @model.position[1] + @parent.parent.model.position[1]
        ]
