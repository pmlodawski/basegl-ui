import {Component} from 'view/Component'
import * as basegl from 'basegl'
import * as style  from 'style'


searcherRoot = 'searcher-root'

export class Searcher extends Component
    cons: (args...) =>
        super args...
        @dom = {}

    updateModel: ({ key:            @key            = @key
                  , mode:           @mode           = @mode
                  , input:          @input          = @input
                  , inputSelection: @inputSelection = null
                  , selected:       @selected       = @selected or 0
                  , entries:        @entries        = @entries or []}) =>
        @entries.forEach (entry) => entry.highlights ?= []
        unless @def?
            root = document.createElement 'div'
            root.id = searcherRoot
            root.style.width = 100 + 'px'
            root.style.height = 200 + 'px'
            # root.style.backgroundColor = '#FF0000'
            @def = basegl.symbol root

    updateView: =>
        @updateResults()
        @updateInput()
        unless @dom.container?
            @dom.container = document.createElement 'div'
            @dom.container.className = 'native-key-bindings ' + style.luna ['input', 'searcher', 'searcher--node']
            @dom.container.appendChild @dom.results
            @dom.container.appendChild @dom.input
            @view.domElement.appendChild @dom.container
        @dom.input.focus()

    updateResults: =>
        unless @dom.results?
            @dom.results = document.createElement 'div'
            @dom.results.className = style.luna ['searcher__results']
            @dom.resultsList = document.createElement 'div'
            @dom.resultsList.className = style.luna ['searcher__results__list']
            @dom.results.appendChild @dom.resultsList

        @dom.resultsList.innerText = ''
        omit = if @selected == 0 then 0 else @selected - 1
        i = omit + 1
        @entries.slice(omit).forEach (entry) =>
            @dom.resultsList.appendChild @renderResult entry, i == @selected
            i++

    renderResult: (entry, selected) =>
        resultName = document.createElement 'div'
        resultName.className = style.luna ['searcher__results__item__name']
        resultName.appendChild @renderPrefix entry.className or ''
        resultName.appendChild @renderHighlights entry.name, entry.highlights

        result = document.createElement 'div'
        resultClasses = ['searcher__results__item']
        resultClasses.push ['searcher__results__item--selected'] if selected
        result.className = style.luna resultClasses
        result.appendChild resultName
        return result

    renderPrefix: (prefix) ->
        prefixSpan = document.createElement 'span'
        prefixSpan.className = style.luna ['searcher__pre']
        prefixSpan.innerHTML = prefix
        return prefixSpan

    renderHighlights: (name, highlights) =>
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

    updateInput: =>
        unless @dom.input?
            @dom.input = document.createElement 'input'
            @dom.input.type = 'text'
        inputClasses = ['searcher__input']
        inputClasses.push ['searcher__input-selected'] if @selected == 0
        @dom.input.className = style.luna inputClasses
        if @inputSelection?.length == 2
            @dom.input.selectionStart = @inputSelection[0]
            @dom.input.selectionEnd   = @inputSelection[1]
            @inputSelection = null
        return @dom.input

    align: (scale) =>
        if @scale != scale
            @scale = scale
            node = @parent.node @key
            if node?
                @group.position.xy = node.position.slice()
                @view.scale.xy = [@scale, @scale]

    registerEvents: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                @align scene.camera.position.z
        @dom.input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'SearcherEdit'
                selectionStart: @dom.input.selectionStart
                selectionEnd:   @dom.input.selectionEnd
                value:          @dom.input.value
        @dom.input.addEventListener 'keyup', (e) =>
            if e.code == 'Enter'
                @pushEvent
                    tag: 'SearcherAccept'
                    selectionStart: @dom.input.selectionStart
                    selectionEnd:   @dom.input.selectionEnd
                    value:          @dom.input.value
