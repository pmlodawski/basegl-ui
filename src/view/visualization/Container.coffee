import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {TextContainer}       from 'view/Text'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'



export class VisualizationContainer extends ContainerComponent
    initModel: =>
        visualizers : null
        visualizations: {}
        value: null

    prepare: =>
        @addDef 'valueToggler', ValueTogglerShape, null

    update: =>
        if @changed.value
            @autoUpdateDef 'value', TextContainer, if @__shortValue()?
                text: @__shortValue()
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        if @changed.visualizations or @changed.visualizers
            @autoUpdateDef 'visualizations', VerticalLayout, if @model.visualizations?
                children: for own k, visualization of @model.visualizations
                    visualization.cons = Visualization
                    visualization.visualizers = @model.visualizers
                    visualization

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

