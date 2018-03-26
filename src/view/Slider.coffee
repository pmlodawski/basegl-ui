import * as basegl from 'basegl'

import * as shape from 'shape/Slider'
import {Widget}   from 'view/Widget'
import * as util  from 'shape/util'


sliderShape = basegl.symbol shape.sliderShape
sliderShape.bbox.xy = [100, 20]
sliderShape.variables.level = 0
sliderShape.variables.topLeft     = 0
sliderShape.variables.topRight    = 0
sliderShape.variables.bottomLeft  = 0
sliderShape.variables.bottomRight = 0

export class Slider extends Widget
    constructor: (values, parent) ->
        super values, parent
        @configure
            minWidth: 40
            minHeight: 20
            width: 100

    updateModel: ({ min:   @min   = @min
                  , max:   @max   = @max
                  , value: value  = @value
                  , position: @position = @position or [0,0]
                  }) =>
        if @def?
            if value != @value
                @value = value
                @createDef()
                @reattach()
        else
            @value = value
            @createDef()

    createDef: =>
            valueShape = basegl.text
                str: @value.toString()
                fontFamily: 'DejaVuSansMono'
                size: 14
            @def = [ {name: 'slider', def: sliderShape}
                   , {name: 'value',  def: valueShape}]

    updateView: =>
        @view.slider.variables.level = (@value - @min)/(@max - @min)
        @view.slider.variables.topLeft     = not (@siblings.top or @siblings.left)
        @view.slider.variables.topRight    = not (@siblings.top or @siblings.right)
        @view.slider.variables.bottomLeft  = not (@siblings.bottom or @siblings.left)
        @view.slider.variables.bottomRight = not (@siblings.bottom or @siblings.right)
        @view.slider.bbox.xy = [@width, @height]
        textSize = util.textSize @view.value
        @view.value.position.xy = [@width/2 - textSize[0]/2 , @height/2 - textSize[1]/2]
        @group.position.xy = @position

    registerEvents: =>
