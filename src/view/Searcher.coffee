import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape} from 'shape/Html'

import * as basegl from 'basegl'
import * as style  from 'style'
import * as shape  from 'shape/node/Base'
import * as focus  from 'view/Focus'

searcherId = 'searcher-input'

export class Searcher extends ContainerComponent

    ################################
    ### Initialize the component ###
    ################################

    initModel: =>
        key: null
        input: null
        inputSelection: null
        selected: 0
        entries: []

    prepare: =>
        @dom = {}
        @addDef 'root', HtmlShape,
            element: 'div'
            scalable: false
            cssClassName: style.luna ['searcher__root']

    #############################
    ### Create/update the DOM ###
    #############################

    update: =>
        @__createDom() unless @dom.container?
        @__updateResults()
        @__updateInput()
        setTimeout => @__focusInput()

    dispose: =>
        focus.focusNodeEditor()
        super()

    __focusInput: =>
        @dom.input.focus()

    __createDom: =>
        @__createResults()
        @__createInput()
        @__createContainer()

    __createContainer: =>
        @dom.container = document.createElement 'div'
        @dom.container.className = style.luna ['input', 'searcher__container']
        @dom.container.appendChild @dom.results
        @dom.container.appendChild @dom.input
        @def('root').getDomElement().appendChild @dom.container

    __createResults: =>
        @dom.results = document.createElement 'div'
        @dom.results.className = style.luna ['searcher__results']
        @dom.resultsList = document.createElement 'div'
        @dom.resultsList.className = style.luna ['searcher__results__list']
        @dom.results.appendChild @dom.resultsList

    __createInput: =>
        @dom.input = document.createElement 'input'
        @dom.input.type = 'text'
        @dom.input.value = @model.input
        @dom.input.className = @__inputClassName()

    __updateResults: =>
        @dom.resultsList.innerText = ''
        return unless @model.entries.length > 0

        firstResult = @__renderResult @model.entries[0], @model.selected != 0
        @dom.resultsList.appendChild firstResult
        @model.entries[1..].forEach (entry) =>
            @dom.resultsList.appendChild @__renderResult entry, false

    __updateInput: =>
        @dom.input.className = @__inputClassName()
        @dom.input.value = @model.input
        if @model.inputSelection?.length == 2
            @dom.input.selectionStart = @model.inputSelection[0]
            @dom.input.selectionEnd   = @model.inputSelection[1]
            @model.inputSelection = null

    __inputClassName: =>
        inputClasses = ['searcher__input']
        inputClasses.push ['searcher__input-selected'] if @model.selected == 0
        inputClasses.push ['searcher__no-results'] if @model.entries.length == 0
        style.luna inputClasses

    __renderResult: (entry, selected) =>
        resultName = document.createElement 'div'
        resultName.className = style.luna ['searcher__results__item__name']
        resultName.appendChild @__renderPrefix entry.className or ''
        resultName.appendChild @__renderHighlights entry.name, entry.highlights

        result = document.createElement 'div'
        resultClasses = ['searcher__results__item']
        resultClasses.push ['searcher__results__item--selected'] if selected
        result.className = style.luna resultClasses
        result.appendChild resultName
        return result

    __renderPrefix: (prefix) ->
        prefixSpan = document.createElement 'span'
        prefixSpan.className = style.luna ['searcher__pre']
        prefixSpan.innerHTML = prefix
        return prefixSpan

    __renderHighlights: (name, highlights) =>
        nameSpan = document.createElement 'span'
        last = 0
        highlights.forEach (highlight) =>
            normName = name.slice last, highlight.start
            highName = name.slice highlight.start, highlight.end
            last = highlight.end

            normSpan = document.createElement 'span'
            normSpan.innerHTML = normName
            nameSpan.appendChild normSpan

            highSpan = document.createElement 'span'
            highSpan.className = style.luna ['searcher__hl']
            highSpan.innerHTML = highName
            nameSpan.appendChild highSpan
        normSpan = document.createElement 'span'
        normSpan.innerHTML = name.slice last
        nameSpan.appendChild normSpan
        return nameSpan

    ###################################
    ### Register the event handlers ###
    ###################################

    registerEvents: =>
        @dom.input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'SearcherEditEvent'
                editSelectionStart: @dom.input.selectionStart
                editSelectionEnd:   @dom.input.selectionEnd
                editValue:          @dom.input.value

        @dom.input.addEventListener 'keyup', (e) =>
            if e.key == 'Enter'
                @pushEvent
                    tag: 'SearcherAcceptEvent'
                    acceptSelectionStart: @dom.input.selectionStart
                    acceptSelectionEnd:   @dom.input.selectionEnd
                    acceptValue:          @dom.input.value
            else if e.key == 'Tab'
                @pushEvent tag: 'SearcherTabPressedEvent'

        @dom.input.addEventListener 'keydown', (e) =>
            if e.key == 'ArrowUp'
                @pushEvent tag: 'SearcherMoveUpEvent'
            else if e.key == 'ArrowDown'
                @pushEvent tag: 'SearcherMoveDownEvent'
