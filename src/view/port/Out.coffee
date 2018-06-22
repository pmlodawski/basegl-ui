import * as shape       from 'shape/port/Base'

import {FlatPortShape}      from 'shape/port/Flat'
import {TextShape}          from 'shape/Text'
import {Port}               from 'view/port/Port'
import {OutArrow}           from 'view/port/sub/OutArrow'


export class OutPort extends Port
    initModel: =>
        key:      null
        typeName: ''
        angle:    0
        radius:   0
        color:    [0, 1, 0]
        subports: {}

    prepare: =>
        @setCons OutArrow

    update: =>
        if (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            for own k, subport of @model.subports
                @autoUpdateDef ('sub' + k), @cons, angle: subport
        else
            @autoUpdateDef 'subport', @cons, angle: @model.angle

    connectionPosition: => @parent.model.position
