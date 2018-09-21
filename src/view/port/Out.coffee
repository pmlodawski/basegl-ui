import {FlatPortShape}      from 'shape/port/Flat'
import {Port, defaultColor} from 'view/port/Base'
import {OutArrow}           from 'view/port/sub/OutArrow'


export class OutPort extends Port
    initModel: =>
        key:      null
        typeName: ''
        angle:    0
        radius:   0
        color:    defaultColor
        subports: {}

    portConstructor: => OutArrow

    update: =>
        if (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            for own k, subport of @model.subports
                @def('subports').autoUpdateDef k, OutArrow,
                    radius: @model.radius
                    typeName: @model.typeName
                    color: @model.color
                    angle: subport
        else
            @updateDef 'subports', elems: []
            @autoUpdateDef 'subport', OutArrow,
                angle: @model.angle
                color: @model.color
                radius: @model.radius
                typeName: @model.typeName

    connectionPosition: => @parent.parent.model.position
