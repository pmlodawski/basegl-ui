import * as basegl from 'basegl'

import {SliderShape} from 'shape/widget/Slider'
import {TextShape}   from 'shape/Text'
import * as util     from 'shape/util'
import * as layers   from 'view/layers'
import {Widget}      from 'widget/Widget'



export class Slider extends Widget
    initModel: ->
        model = super()
        model.minWidth = 40
        model.minHeight = 20
        model.min = null
        model.max = null
        model.value = null
        model

    prepare: =>
        @addDef 'value', new TextShape
                fontFamily: 'DejaVuSansMono'
                size: 14
                align: 'center'
                text: '19'
            , @
        @addDef 'slider', new SliderShape null, @

    update: =>
        @updateDef 'value', text: @model.value.toString()
        @updateDef 'slider',
            level:       (@model.value - @model.min)/(@model.max - @model.min)
            topLeft:     not (@model.siblings.top or @model.siblings.left)
            topRight:    not (@model.siblings.top or @model.siblings.right)
            bottomLeft:  not (@model.siblings.bottom or @model.siblings.left)
            bottomRight: not (@model.siblings.bottom or @model.siblings.right)
            width:       @model.width
            height:      @model.height
    adjust: (view) =>
        if @changed.width  then @view('value').position.x = @model.width/2
        if @changed.height then @view('slider').position.y = -@model.height/2

    registerEvents: =>
