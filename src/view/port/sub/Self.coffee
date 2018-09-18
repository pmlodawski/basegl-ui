import {SelfPortShape} from 'shape/port/Self'
import {Subport}       from 'view/port/sub/Base'
import * as subport    from 'view/port/sub/Base'
import {TextContainer} from 'view/Text'


export class Self extends Subport
    initModel: =>
        angle:    0
        hovered:  false
        typeName: ''
        radius:   0
        color:    [0, 1, 0]

    prepare: =>
        @addDef 'port', SelfPortShape, null

    update: =>
        @autoUpdateDef 'typeName', TextContainer,
            text: @model.typeName
            align: 'left'
            color: [@style.text_color_r, @style.text_color_g, @style.text_color_b, @model.hovered]

    adjust: (view) =>
        if @view('typeName')?
            @view('typeName').rotation.z = @model.angle - Math.PI/2
            typeNamePosition = [- subport.typeNameXOffset(@style) - @model.radius, 0]
            @view('typeName').position.xy = typeNamePosition

    connectSources: =>
        @__onTypeNameChange()
        @__onRadiusChange()
        @__onColorChange()
        @__onHoverChange()
        @addDisposableListener @parent, 'typeName', => @__onTypeNameChange()
        @addDisposableListener @parent, 'radius', => @__onRadiusChange()
        @addDisposableListener @parent, 'color', => @__onColorChange()
        @addDisposableListener @parent.parent.parent, 'hovered', => @__onHoverChange() #TODO: Refactor

    __onTypeNameChange: =>
        @set typeName: @parent.model.typeName
    __onRadiusChange: =>
        @set radius: @parent.model.radius
    __onColorChange: =>
        @updateDef 'port', color: @parent.model.color
    __onHoverChange: =>
        @set hovered: @parent.parent.parent.model.hovered
