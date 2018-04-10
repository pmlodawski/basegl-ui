import {Component} from 'view/Component'
import * as basegl from 'basegl'
import * as style  from 'style'


searcherRoot = 'searcher-root'

export class Searcher extends Component
    updateModel: ({ key: @key = @key
                  , mode: @mode = @mode
                  , input: @input = @input
                  , selected: @selected = @selected or 0
                  , entries: @entries = @entries or []}) =>
        @entries.forEach (entry) => entry.highlights ?= []
        unless @def?
            root = document.createElement 'div'
            root.id = searcherRoot
            root.style.width = 100 + 'px'
            root.style.height = 200 + 'px'
            # root.style.backgroundColor = '#FF0000'
            @def = basegl.symbol root

    updateView: =>
        @view.domElement.innerHTML = ''

        container = document.createElement 'div'
        container.className = 'native-key-bindings ' + style.luna ['input', 'searcher', 'searcher--node']
        container.appendChild @renderResults() if @entries.length > 0
        container.appendChild @renderInput()
        @view.domElement.appendChild container

    renderResults: =>
        results = document.createElement 'div'
        results.className = style.luna ['searcher__results']

        resultsList = document.createElement 'div'
        resultsList.className = style.luna ['searcher__results__list']
        results.appendChild resultsList

        i = 0
        @entries.slice(@selected).forEach (entry) =>
            resultsList.appendChild @renderResult entry, i
            i++

        return results

    renderResult: (entry, entryNo) =>
        resultName = document.createElement 'div'
        resultName.className = style.luna ['searcher__results__item__name']
        resultName.appendChild @renderPrefix entry.className or ''
        resultName.appendChild @renderHighlights entry.name, entry.highlights

        result = document.createElement 'div'
        resultClasses = ['searcher__results__item']
        resultClasses.push ['searcher__results__item--selected'] if entryNo == 0
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

    renderInput: =>
        input = document.createElement 'input'
        inputClasses = ['searcher__input']
        inputClasses.push ['searcher__input-selected'] if @selected == 0
        input.className = style.luna inputClasses
        return input

    align: (scale) =>
        if @scale != scale
            @scale = scale
        node = @parent.node(@key)
        if node?
            @group.position.xy = node.position.slice()
            @view.scale.xy = [@scale, @scale]

    registerEvents: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                @align scene.camera.position.z
