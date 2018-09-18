import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {TextContainer}       from 'view/Text'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'
import {Parameters}         from 'view/Parameters'



export class NodeBody extends ContainerComponent
    initModel: =>
        expanded: false
        inPorts: {}
        visualizers : null
        visualizations: {}
        value: null

    prepare: =>
        @addDef 'valueToggler', ValueTogglerShape
        @addDef 'modules', VerticalLayout,
            width: @style.node_bodyWidth

    update: =>
        if @changed.value
            @autoUpdateDef 'value', TextContainer, if @__shortValue()?
                text: @__shortValue()
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        if @changed.visualizations or @changed.visualizers or @changed.inPorts or @changed.expanded
            modules = []
            if @model.expanded
                modules.push
                    cons: Parameters
                    inPorts: @model.inPorts
            for own k, visualization of @model.visualizations
                visualization.cons = Visualization
                visualization.visualizers = @model.visualizers
                modules.push visualization
            @updateDef 'modules', children: modules

    adjust: =>
        @view('value')?.position.x = @style.node_bodyWidth/2
        @view('valueToggler').position.xy =
            [ @style.visualization_togglerX, @style.visualization_togglerY ]
    
    registerEvents: =>
        @view('valueToggler').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'ToggleVisualizationsEvent'

    __shortValue: =>
        @model.value?.contents?.contents

