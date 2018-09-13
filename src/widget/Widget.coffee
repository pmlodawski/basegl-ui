import * as basegl    from 'basegl'

import {ContainerComponent}  from 'abstract/ContainerComponent'


export class Widget extends ContainerComponent
    initModel: =>
        width:     null
        height:    null
        inline:    false
        siblings:
            top:    false
            bottom: false
            left:   false
            right:  false

    minWidth: => @__minWidth or 0
    optWidth: => @__optWidth or 100
    maxWidth: => @__maxWidth or Infinity

    minHeight: => @__minHeight or 0
    optHeight: => @__optHeight or 100
    maxHeight: => @__maxHeight or Infinity
