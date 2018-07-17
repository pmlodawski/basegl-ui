import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerMenu} from 'view/visualization/Menu'

export class VisualizationContainer extends ContainerComponent
    initModel: =>
        key : null
        mode : null
        visualizers : null
        visualizer : null
        position : [0, 0]

    prepare: =>
        @addDef 'menu', new VisualizerMenu @model, @

