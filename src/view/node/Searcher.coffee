import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {Expression}          from 'view/node/Expression'
import {Parameters}          from 'view/node/Parameters'
import {TextContainer}       from 'view/Text'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'


export class Searcher extends ContainerComponent
    initModel: =>
        key: null
        entries: []
        input: ''
        inputSelection: [0,0]
        selected: 0
        targetField: 'expression'

    prepare: =>
        @addDef 'body', VerticalLayout, children:
            [
                id: 'hints'
                cons: VerticalLayout
            ]
