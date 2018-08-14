import * as basegl               from 'basegl'
import {ContainerComponent}      from 'abstract/ContainerComponent'
import * as shape                from 'shape/Visualization'
import {VisualizationCoverShape} from 'shape/Visualization'
import {ValueTogglerShape}       from 'shape/visualization/ValueToggler'
import {TextContainer}           from 'view/Text'
import {VisualizationIFrame}     from 'view/visualization/IFrame'
import {VerticalLayout}          from 'widget/VerticalLayout'

export class VisualizationContainer extends ContainerComponent
    initModel: =>
        visualization: null
        visualizers:   null

    prepare: =>
        @addDef 'container', VisualizationCoverShape, null
        @addDef 'iframe', VisualizationIframe, null
        @addDef 'menu', VisualizerMenu, null

    update: =>
        if @changed.visualization
            @autoUpdateDef 'iframe', VisualizationIframe, @model.visualization
        if @changed.visualizers
            @autoUpdateDef 'menu', VisualizerMenu, @model.visualizers

    adjust: =>
        # we should consider mode here and make adjustment. VisualizerMenu does not need mode if it is positioned here. Iframe needs it to be moved to correct layer
        @view('container').position.xy     = [-shape.width/2, -shape.height]
        @view('visualization').position.xy = [-shape.width/2, -shape.height]
        @view('menu').position.xy          = [-shape.width/2 - 10, 0]

    registerEvents: =>
        @view('container').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'FocusVisualizationEvent'
