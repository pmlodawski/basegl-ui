import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort, OutPort} from 'view/Port'
import {Component}       from 'view/Component'
import * as shape        from 'shape/Visualization'
import * as util         from 'shape/util'
import * as nodeShape    from 'shape/Node'
import {Widget}          from 'view/Widget'
import * as style        from 'style'
import * as path         from 'path'


visualizationShape = basegl.symbol shape.visualizationShape

export class VisualizationContainer extends Component
    updateModel: ({ nodeKey:        @nodeKey            = @nodeKey
                  , visualizers:     visualizers        = @visualizers
                  , visualizations:  visualizations }) =>
        if visualizers != @visualizers
            @visualizers = visualizers
        if visualizations?
            @visualizations ?= {}
            pos = @getPosition()
            newVisualizations = {}

            for vis in visualizations
                vis.visualizers = @visualizers
                vis.position    = pos
                if @visualizations[vis.key]?
                    newVisualizations[vis.key] = @visualizations[vis.key]
                    newVisualizations[vis.key].set vis
                else
                    newVis = new Visualization vis, @
                    newVisualizations[vis.key] = newVis
                    newVis.attach()

            for own key of @visualizations
                unless newVisualizations[key]?
                    @visualizations[key].dispose()

            @visualizations = newVisualizations

    dispose: =>
        for key in @visualizations
            if @visualizations.hasOwnProperty key
               @visualizations[key].dispose()

    getPosition: =>
        node = @parent.node @nodeKey
        offset = if node.expanded
                [ nodeShape.width/2
                , - node.bodyHeight - nodeShape.height/2 - nodeShape.slope ]
            else [ 0, - nodeShape.height/2 ]

        return [ node.position[0] + offset[0]
            , node.position[1] + offset[1]]


    updateVisualizationsPositions: =>
        pos = @getPosition()
        for own key of @visualizations
            @visualizations[key].set position: pos

    registerEvents: =>
        node = @parent.node @nodeKey
        @addDisposableListener node, 'position', => @updateVisualizationsPositions()
        @addDisposableListener node, 'expanded', => @updateVisualizationsPositions()

export class Visualization extends Widget
    constructor: (args...) ->
        super args...
        @configure
            height: 300
            width:  200

    updateModel: ({ key:                @key                = @key
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , selectedVisualizer:  selectedVisualizer = @selectedVisualizer
                  , visualizers:         visualizers        = @visualizers
                  , position:            position           = @position or [0,0] }) =>
        if @mode != mode or @currentVisualizer != currentVisualizer or @selectedVisualizer != selectedVisualizer or @visualizers != visualizers or @position != position
            @mode               = mode
            @currentVisualizer  = currentVisualizer
            @selectedVisualizer = selectedVisualizer
            @visualizers        = visualizers
            @position           = position
            unless @def?
                root = document.createElement 'div'
                root.id = @key
                root.style.width = 200 + 'px'
                root.style.height = 300 + 'px'
                root.style.backgroundColor = '#FF0000'
                @def = basegl.symbol root
            if @view?
                @reattach

    updateView: =>
        @view.domElement.innerHTML = ''
        container = document.createElement 'div'
        container.className = style.luna ['dropdown']
        container.appendChild @renderVisualization()
        container.appendChild @renderVisualizerMenu()
        @view.domElement.appendChild container
        @group.position.xy = [@position[0], @position[1] - @height/2]

    renderVisualization: =>
        vis = document.createElement 'div'
        visPaths = @parent.parent.visualizerLibraries
        visType = @currentVisualizer.visualizerType
        pathPrefix = if visType == 'InternalVisualizer'
                visPaths.internalVisualizersPath
            else if visType == 'LunaVisualizer'
                visPaths.lunaVisualizersPath
            else visPaths.projectVisualizersPath
        if pathPrefix?
            url = path.join pathPrefix, @currentVisualizer.visualizerPath
            vis.innerHTML = '<iframe style="width:100%;height:100%;" frameborder="0" src="' + url + '" />'
        return vis
        
    renderVisualizerMenu: =>
        menu = document.createElement 'ul'
        menu.className = style.luna ['dropdown__menu']

        for visualizer in @visualizers
            menu.appendChild (@renderVisualizerMenuEntry visualizer)
        return menu

    renderVisualizerMenuEntry: (visualizer) =>
        entry = document.createElement 'li'
        entry.appendChild document.createTextNode visualizer.visualizerName
        return entry
