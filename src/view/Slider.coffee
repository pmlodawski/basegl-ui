import * as basegl    from 'basegl'

import * as shape       from 'shape/Slider'
import {Component}  from 'view/Component'
import * as util         from 'shape/util'


sliderShape = basegl.symbol shape.sliderShape
sliderShape.bbox.xy = [100, 20]
sliderShape.variables.level = 0

export class Slider extends Component
    constructor: (values, parent) ->
        super values, parent
        @width = 150
        @height = 20

    updateModel: ({ min:   @min   = @min
                  , max:   @max   = @max
                  , value: @value = @value
                  }) =>
        unless @def?
            valueShape = basegl.text
                str: @value.toString()
                fontFamily: 'DejaVuSansMono'
                size: 14
            @def = [ {name: 'slider', def: sliderShape}
                   , {name: 'value',  def: valueShape}]

    updateView: =>
        @view.slider.variables.level = (@value - @min)/(@max - @min)
        @view.slider.bbox.xy = [@width, @height]
        textSize = util.textSize @view.value
        @view.value.position.xy = [@width/2 - textSize[0]/2 , @height/2 - textSize[1]/2]

    registerEvents: =>
