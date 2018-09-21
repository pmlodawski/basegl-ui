import {animateComponent} from 'shape/Animation'
import {InPortShape}      from 'shape/port/In'
import {TextContainer}    from 'view/Text'
import {Subport}          from 'view/port/sub/Base'
import * as subport       from 'view/port/sub/Base'


export class InArrow extends Subport
    initModel: =>
        angle: 0
        connected: false
        color: [1, 0, 0]
        hovered: false
        name: ''
        typeName: ''
        radius: 0

    prepare: =>
        @addDef 'port', InPortShape, angle: @model.angle

    update: =>
        @autoUpdateDef 'name', TextContainer, if @model.name
            text: @model.name
            align: 'right'
            border: @style.port_nameBorder
            frameColor:
                [ @style.port_borderColor_h, @style.port_borderColor_s
                , @style.port_borderColor_l, @style.port_borderColor_a * (@model.hovered or @model.connected)] # or not(@model.connected))
            color: [ @model.color[0], @model.color[1]
                   , @model.color[2], (@model.hovered or @model.connected) ]
        @autoUpdateDef 'typeName', TextContainer, if @model.typeName
            text: @model.typeName
            align: 'right'
            border: @style.port_typeBorder
            color: [@model.color[0], @model.color[1],
                    @model.color[2], @model.hovered]
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.radius
            @animatePositionY @view('port'), @model.radius
            namePosition = [- subport.nameXOffset(@style) - @model.radius, 0]
            @animatePosition @view('name'), namePosition
        if @changed.angle
            @animateRotation @view('port'), @model.angle
            @animateRotation @view('name'), @model.angle - Math.PI/2
        @animateRotation @view('typeName'), @model.angle - Math.PI/2
        typeNamePosition = [- subport.typeNameXOffset(@style) - @model.radius, - subport.typeNameYOffset(@style)]
        @animatePosition @view('typeName'), typeNamePosition

    registerEvents: (view) =>
        super view
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent e
