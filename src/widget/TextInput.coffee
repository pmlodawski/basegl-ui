import * as basegl from 'basegl'

import {HtmlShape}   from 'shape/Html'
import * as util     from 'shape/util'
import * as layers   from 'view/layers'
import {Widget}      from 'widget/Widget'



export class TextInput extends Widget
    initModel: ->
        model = super()
        model.value = ''
        model

    prepare: =>
        @addDef 'input', new HtmlShape
                element: 'input'
            , @

    update: =>

    adjust: (view) =>
        view.position.xy = [100, 0]
