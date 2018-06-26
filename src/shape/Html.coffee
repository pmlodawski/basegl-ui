import * as util         from 'shape/util'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'

    redefineRequired: =>
        @changed.id or @changed.element

    define: =>
        root = document.createElement @model.element
        root.id = @model.id if @model.id?
        basegl.symbol root
