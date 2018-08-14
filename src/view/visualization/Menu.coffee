import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerButton}   from 'shape/visualization/Button'
import {TextContainer}      from 'view/Text'
import {VerticalLayout}     from 'widget/VerticalLayout'

export class VisualizerMenu extends ContainerComponent
    initModel: =>
        key: null
        visualizers : null
        selectedVisualizer: null # needed for highlight
        expanded: false

    prepare: =>
        @addDef 'button', VisualizerButton, null

    update: =>
        # use selectedVisualizer to highlight current one
        if @changed.expanded or @changed.visualizers or @changed.selectedVisualizer
            children = []
            if @model.visualizers?
                @model.visualizers.forEach (visualizer) =>
                    children.push
                        cons: TextContainer
                        text: visualizer.visualizerName
                        align: 'right'
                        onclick: (e) =>
                            e.stopPropagation()
                            @pushEvent
                                tag: 'SelectVisualizerEvent'
                                visualizerId: visualizer
                            @set expanded: false
                @autoUpdateDef 'list', VerticalLayout, if @model.expanded
                    children: children
    adjust: =>
        @view('list')?.position.xy = [10, -15]

    # I am not sure if this is safe
    registerEvents: =>
        @view('button').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @set expanded: not @model.expanded
