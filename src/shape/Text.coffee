import * as util         from 'shape/util'
import {BasicComponent}  from 'abstract/BasicComponent'

export class TextShape extends BasicComponent
    initModel: =>
        text: ''
        align: 'center'
    redefineRequired: =>
        @changed.text
    define: =>
        util.text str: @model.text
    adjust: (element) =>
        element.position.x =
            if @model.align == 'center'
                -util.textWidth(element) / 2
            else if @model.align == 'right'
                -util.textWidth(element)
            else
                0
        element.position.y = - util.textHeight(element)/2
