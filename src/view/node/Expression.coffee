import {Background}       from 'shape/node/Background'
import {Widget}           from 'widget/Widget'
import {EditableText}        from 'view/EditableText'


export class Expression extends Widget
    initModel: =>
        model = super()
        model.expression = ''
        model.editing = false
        model

    prepare: =>
        @addDef 'expression', EditableText,
            color: [@style.text_color_r, @style.text_color_g, @style.text_color_b]
            width: @style.node_bodyWidth
        @addDef 'background', Background,
            width: @style.node_bodyWidth

    update: =>
        if @changed.editing
            @updateDef 'expression', editing: @model.editing
        if @changed.expression
            @updateDef 'expression',
                text:  @model.expression
            @__minHeight = @def('expression').height() + 2*@style.node_widgetOffset_v
            @updateDef 'background', height: @__minHeight
        if @changed.siblings
            @updateDef 'background',
                roundBottom: not @model.siblings.bottom
                roundTop:    not @model.siblings.top
    adjustSrc: (view) =>
        view.position.xy = [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @view('expression').scale.xy = [0,0]
        @view('background').scale.xy = [0,0]

    adjustDst: (view) =>
        @setPosition view, [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @setScale @view('expression'), [0,0]
        @setScale @view('background'), [0, 0]

    adjust: (view) =>
        if @changed.once
            @setPosition view, [0, 0]
            @setScale @view('expression'), [1, 1]
            @setScale @view('background'), [1, 1]
            @view('expression').position.xy = [@style.node_bodyWidth/2, - @__minHeight/2]

    registerEvents: =>
        @def('expression').addEventListener 'editing', (e) =>
            input = @def('expression').model
            @pushEvent \
                if e.detail
                    tag: 'EditNodeExpressionEvent'
                else
                    tag: 'SearcherAcceptEvent'
                    acceptSelectionStart: 0
                    acceptSelectionEnd:   0
                    acceptValue:          input.text
        @def('expression').addEventListener 'modelUpdated', =>
            @__pushSearcherEdit()

    __pushSearcherEdit: =>
        input = @def('expression').model
        if input.editing && input.selection?
            @pushEvent
                tag: 'SearcherEditEvent'
                editSelectionStart: input.selection[0]
                editSelectionEnd:   input.selection[1]
                editValue:          input.text
