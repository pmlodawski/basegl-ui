import {Widget}     from 'widget/Widget'
import {FramedText} from 'widget/FramedText'
import {TextInput}  from 'widget/TextInput'



export class EditableText extends Widget
    initModel: =>
        model = super()
        model.text = ''
        model.color = null
        model.frameColor = null
        model.editing = false
        model.textAlign = 'center'
        model.selection = null
        model

    update: =>
        @autoUpdateDef 'input', TextInput, if @model.editing
            value:      @model.text
            selection:  @model.selection
            color:      @model.color
            frameColor: @model.frameColor
            height:     @model.height
            width:      @model.width
            textAlign:  @model.textAlign
        @autoUpdateDef 'text', FramedText, unless @model.editing
            text:       @model.text
            color:      @model.color
            frameColor: @model.frameColor
            height:     @model.height
            width:      @model.width
            textAlign:  @model.textAlign
        if @changed.editing
            if @model.editing
                @__minHeight = @def('input').__minHeight
                @__minWidth  = @def('input').__minWidth
                @def('input').addEventListener 'escape', => @__exitEditing()
                @def('input').addEventListener 'enter',  => @__exitEditing()
                @def('input').addEventListener 'blur',   => @__exitEditing()
                @def('input').addEventListener 'value',     => @__setInput()
                @def('input').addEventListener 'selection', => @__setInput()
                setTimeout => @def('input').focus()
            else
                @__minHeight = @def('text').__minHeight
                @__minWidth  = @def('text').__minWidth
                @view('text').addEventListener 'dblclick', (e) =>
                    e.stopPropagation()
                    @set editing: true

    adjust: =>
        @view('input')?.position.x = - @width()/2
        @view('text')?.position.x = - @width()/2

    __setInput: =>
        input = @def('input').model
        @set
            selection: input.selection
            text: input.value

    __exitEditing: =>
        @set
            editing: false
            selection: null
