import {ContainerComponent} from 'abstract/ContainerComponent'
import {TextShape}          from 'shape/Text'
import {RectangleShape}     from 'shape/Rectangle'
import * as color           from 'shape/Color'


export class TextContainer extends ContainerComponent
    initModel: =>
        text: ''
        align: 'center'
        frameColor: [0,0,0]
        frameVisible: false

    prepare: =>
        @addDef 'text', new TextShape
                text: @model.text
                align: @model.align
            , @
        @addDef 'box', new RectangleShape
                visible: @model.frameVisible
                color: @model.frameColor
            , @

    update: =>
        if @changed.text
            @updateDef 'text',
                text: @model.text
        if @changed.align
            @updateDef 'text',
                align: @model.align
        if @changed.text
            @size = @def('text').size()
            @updateDef 'box', size: @size.slice()
        if @changed.frameVisible
            @updateDef 'box', visible: @model.frameVisible
        if @changed.frameColor
            @updateDef 'box', color: @model.frameColor

    adjust: =>
        if @changed.text or @changed.align
            x = if @model.align == 'right'
                    -@size[0]
                else if @model.align == 'center'
                    -@size[0]/2
                else
                    0
            @view('box').position.xy = [x, -@size[1]/2]
