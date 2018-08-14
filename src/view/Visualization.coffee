import * as basegl               from 'basegl'
import {ContainerComponent}      from 'abstract/ContainerComponent'
import * as shape                from 'shape/Visualization'
import {VisualizationCoverShape} from 'shape/Visualization'
import {ValueTogglerShape}       from 'shape/visualization/ValueToggler'
import {TextContainer}           from 'view/Text'
import {VisualizationIFrame}     from 'view/visualization/IFrame'
import {VerticalLayout}          from 'widget/VerticalLayout'

export class NodeVisualizations extends ContainerComponent
    initModel: =>
        visualizers: null
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
            visualizations = []
            if @model.visualizations?
                for k, visualization of @model.visualizations
                    unless visualization.currentVisualizer?
                        continue
                    vis.visualizers = {
                        key: visualization.key
                        visualizers: @model.visualizers
                        selectedVisualizer: visualization.selectedVisualizer
                    }
                    vis.visualization = visualization
                    vis.visualization.selectedVisualizer = null # to not trigger iframe update if selected changed
                    vis.cons = Visualization
                    visualizations.push vis
            @autoUpdateDef 'visualizations', VerticalLayout, if visualizations.length > 0
                children: visualizations
    adjust: =>
        @view('visualizations').position.xy = [-shape.width/2, -shape.height]
        @view('valueToggler').position.xy  = [-shape.width/2 - 30, 0]

    __shortValue: =>
        if @model.value? and @model.value.contents?
            @model.value.contents.contents