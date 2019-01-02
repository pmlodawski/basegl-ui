import {ContainerComponent}  from 'abstract/ContainerComponent'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'
import {Hints}               from 'view/node/Hints'


export class Searcher extends ContainerComponent
    initModel: =>
        key: null
        entries: []
        input: ''
        inputSelection: [0,0]
        selected: 0
        targetField: 'expression'

    prepare: =>
        @addDef 'body', VerticalLayout,
            width: @style.node_bodyWidth

    update: =>
        if @changed.entries or @changed.selected
            @updateDef 'body', children: [
                id: 'hints'
                cons: Hints
                entries: @model.entries
                selected: @model.selected
            ]
