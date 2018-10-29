import * as basegl    from 'basegl'

import {ContainerComponent}  from 'abstract/ContainerComponent'


export class Widget extends ContainerComponent
    initModel: =>
        width:     undefined
        height:    undefined
        inline:    false
        siblings:
            top:    false
            bottom: false
            left:   false
            right:  false

    minWidth: => @__minWidth or 0
    maxWidth: => @__maxWidth or Infinity

    minHeight: => @__minHeight or 0
    maxHeight: => @__maxHeight or Infinity

    width: => @model.width or @__minWidth
    height: => @model.height or @__minHeight
