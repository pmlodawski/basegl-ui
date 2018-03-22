import * as basegl    from 'basegl'

import {Component}  from 'view/Component'



export class Widget extends Component
    constructor: (values, parent) ->
        super values, parent

    configure: ({ minWidth:  @minWidth  = @minWidth or 0
                , minHeight: @minHeight = @minHeight or 0
                , maxWidth:  @maxWidth  = @maxWidth
                , maxHeight: @maxHeight = @maxHeight
                , width:     @width  = @width
                , height:    @height = @height
                , inline:    @inline = @inline or false
                , siblings:  @siblings = @siblings or {}
                }) =>
        @width ?= @minWidth
        @height ?= @minHeight
        @siblings.top    ?= false
        @siblings.bottom ?= false
        @siblings.left   ?= false
        @siblings.right  ?= false
        @updateView() if @view?
