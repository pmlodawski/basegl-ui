import {Widget}     from 'widget/Widget'
import {FramedText} from 'view/Text'
import {TextInput}  from 'widget/TextInput'



export class EditableText extends Widget
    initModel: =>
        model = super()
        model.text = ''
        model.color = null
        model.frameColor = null
        model.editing = true
        model.textAlign = 'center'
        model

    update: =>
        @autoUpdateDef 'input', TextInput, if @model.editing
            value:      @model.text
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

        if @model.editing
            @__minHeight = @def('input').__minHeight
            @__minWidth  = @def('input').__minWidth
        else
            @__minHeight = @def('text').__minHeight
            @__minWidth  = @def('text').__minWidth

    adjust: =>
        @view('input')?.position.x = - @width()/2
        @view('text')?.position.x = - @width()/2
