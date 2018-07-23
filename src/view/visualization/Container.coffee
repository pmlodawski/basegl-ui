import {ContainerComponent}  from 'abstract/ContainerComponent'
import {VisualizerMenu}      from 'view/visualization/Menu'
import {TextContainer}       from 'view/Text'
import {ValueTogglerShape}   from 'shape/node/ValueToggler'
import {VisualizationIFrame} from 'view/visualization/IFrame'
import {VerticalLayout}      from 'widget/VerticalLayout'

export class VisualizationContainer extends ContainerComponent
    initModel: =>
        visualizers : null
        visualizations: null
        value: null

    prepare: =>
        @addDef 'menu', VisualizerMenu, null
        @addDef 'valueToggler', ValueTogglerShape, null

    update: =>
        if @changed.value
            @autoUpdateDef 'value', TextContainer, if @__shortValue()?
                text: @__shortValue()
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        if @changed.visualizers
            @updateDef 'menu', visualizers: @model.visualizers
        if @changed.visualizations
            visualizations = []
            if @model.visualizations?
                for visualization in @model.visualizations
                    visualization.visualizers = @model.visualizers
                    visualization.cons = VisualizationIFrame
                    visualizations.push visualization
            @autoUpdateDef 'visualizations', VerticalLayout, if visualizations.length > 0
                children: visualizations

    adjust: =>
        @view('value')?.position.xy = [50, 0]
        @view('valueToggler').position.xy = [30, 0]

    registerEvents: =>
        @view('valueToggler').addEventListener 'mouseup', (e) => @pushEvent e,
            tag: 'ToggleVisualizationsEvent'

    __shortValue: =>
        if @model.value? and @model.value.contents?
            @model.value.contents.contents

