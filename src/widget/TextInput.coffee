import {HtmlShape}      from 'shape/Html'
import {RectangleShape} from 'shape/Rectangle'
import * as style       from 'style'
import * as layers      from 'view/layers'
import {Widget}         from 'widget/Widget'


export class TextInput extends Widget
    initModel: ->
        model = super()
        model.value = ''
        model.selection = null
        model.color = null
        model.frameColor = [@style.bgColor_h, @style.bgColor_s, @style.bgColor_l]
        model.textAlign = 'center'
        model

    prepare: =>
        @__minHeight = 20
        @__minWidth = 10
        @addDef 'div', HtmlShape, element: 'div'
        @input = document.createElement 'input'
        @input.className = 'native-key-bindings'
        @input.style.background = 'none'
        @input.style.border = 'none'
        @input.style.outline = 'none'
        @def('div').getDomElement().appendChild @input
        @addDef 'background', RectangleShape,
            color: @model.frameColor

    update: =>
        if @changed.siblings or @changed.width or @changed.height
            @updateDef 'background',
                height: @height()
                width: @width()
                corners:
                    topLeft    : not (@model.siblings.top    or @model.siblings.left)
                    topRight   : not (@model.siblings.top    or @model.siblings.right)
                    bottomLeft : not (@model.siblings.bottom or @model.siblings.left)
                    bottomRight: not (@model.siblings.bottom or @model.siblings.right)
                    round: @height()/2
        if @changed.textAlign
            @input.style.textAlign = @model.textAlign
        if @changed.width
            @input.style.width = @width() + 'px'
        if @changed.height
            @input.style.height = @height() + 'px'
        if @changed.value
            if @input.value != @model.value
                @input.value = @model.value
        if @changed.selection && @model.selection?
            if @input.selectionStart != @model.selection[0]
                @input.selectionStart = @model.selection[0]
            if @input.selectionEnd != @model.selection[1]
                @input.selectionEnd = @model.selection[1]
        if @changed.color
            @input.style.color = @model.color

    adjust: (view) =>
        @view('div').position.xy = [@width()/2, 0]
        @view('background').position.y = -@height()/2

    registerEvents: (view) =>
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @__setInput()
        @input.addEventListener 'blur', =>
            @__setInput()
            @emitProperty 'blur', @input.value
        @input.addEventListener 'keydown', (e) =>
            @__setInput()
            switch e.key
                when 'Escape' then @emitProperty 'escape', @input.value
                when 'Enter'  then @emitProperty 'enter', @input.value
        @input.addEventListener 'input', (e) =>
            @__setInput()

    __setInput: => @set
        selection: [@input.selectionStart, @input.selectionEnd]
        value: @input.value

    focus: => @input.focus()
