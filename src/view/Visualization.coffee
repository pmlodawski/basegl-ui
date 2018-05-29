import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort, OutPort}      from 'view/Port'
import {Component, pushEvent} from 'view/Component'
import * as shape             from 'shape/Visualization'
import * as util              from 'shape/util'
import * as nodeShape         from 'shape/Node'
import {Widget}               from 'view/Widget'
import * as style             from 'style'
import * as path              from 'path'

import * as _ from 'underscore'


visualizationCoverShape = basegl.symbol shape.visualizationCover

export class NodeVisualizations extends Component
    updateModel: ({ nodeKey:        @nodeKey            = @nodeKey
                  , visualizers:     visualizers        = @visualizers
                  , visualizations:  visualizations }) =>
        if not _.isEqual(visualizers, @visualizers)
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
                    newVis = new VisualizationContainer vis, @
                    newVisualizations[vis.key] = newVis
                    newVis.attach()

            for own key of @visualizations
                unless newVisualizations[key]?
                    @visualizations[key].dispose()

            @visualizations = newVisualizations

    dispose: =>
        for own key of @visualizations
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

    withNodeKey: (fun) =>
        fun @nodeKey

export class VisualizationContainer extends Widget
    cons: (args...) ->
        super args...
        @configure
            height: shape.height
            width:  shape.width

    updateModel: ({ key:                @key                = @key
                  , iframeId:            iframeId           = @iframeId
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , selectedVisualizer:  selectedVisualizer = @selectedVisualizer
                  , visualizers:         visualizers        = @visualizers
                  , position:            position           = @position or [0,0] }) =>
        updateVis  = false
        updateMenu = false

        if @position != position
            @position  = position
            updateVis  = true
            updateMenu = true


        if @iframeId != iframeId or @mode != mode or not _.isEqual(@currentVisualizer, currentVisualizer)
            @iframeId          = iframeId
            @mode              = mode
            @currentVisualizer = currentVisualizer
            updateVis          = true
            
            
        if @mode != mode or not _.isEqual(@selectedVisualizer, selectedVisualizer) or not _.isEqual(@visualizers, visualizers)
            @mode               = mode
            @selectedVisualizer = selectedVisualizer
            @visualizers        = visualizers
            updateMenu          = true
        
        if updateVis
            @updateVisualization()
        if updateMenu
            @updateVisualizerMenu()    

        unless @def?
            @def = visualizationCoverShape

    updateVisualization: =>
        vis = {
            key: @key,
            iframeId: @iframeId,
            mode: @mode,
            currentVisualizer: @currentVisualizer,
            position: @position
        }
        if @visualization?
            @visualization.set vis
        else
            vis = new Visualization vis, @
            @visualization = vis
            vis.attach()

    updateVisualizerMenu: =>
        if @visualizers?.length
            vm = {
                key: @key,
                mode: @mode,
                visualizers: @visualizers,
                visualizer: @selectedVisualizer,
                position: @position
            }
            if @visualizerMenu?
                @visualizerMenu.set vm
            else
                vm = new VisualizerMenu vm, @
                @visualizerMenu = vm
                vm.attach()
        else if @visualizerMenu?
            @visualizerMenu.dispose()


    updateView: =>
        @group.position.xy = [@position[0] - shape.width/2, @position[1] - shape.height]
        @view.bbox.xy = [shape.width, shape.height]

    dispose: =>
        @visualization.dispose()
        if @visualizerMenu?
            @visualizerMenu.dispose()

    withNodeKey: (fun) =>
        @parent.withNodeKey fun

export class Visualization extends Widget
    constructor: (args...) ->
        super args...
        @configure
            height: shape.height
            width:  shape.width

    updateModel: ({ key:                @key                = @key
                  , iframeId:            iframeId           = @iframeId
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , position:            position           = @position or [0,0] }) =>
        @rerender = false
        if @position != position
            @position = position
        if @iframeId != iframeId or @mode != mode or not _.isEqual(@currentVisualizer, currentVisualizer)
            @iframeId          = iframeId
            @mode              = mode
            @currentVisualizer = currentVisualizer
            @rerender          = true
            unless @def?
                root = document.createElement 'div'
                root.id           = @key
                root.style.width  = @width + 'px'
                root.style.height = @height + 'px'
                @def = basegl.symbol root    
            if @view?
                @reattach()

    updateView: =>
        @group.position.xy = [@position[0], @position[1] - @height/2]
        if @rerender
            @view.domElement.innerHTML = ''
            @view.domElement.appendChild @renderVisualization()

    renderVisualization: =>
        iframe = document.createElement 'iframe'
        visPaths = @parent.parent.parent.visualizerLibraries
        visType = @currentVisualizer.visualizerId.visualizerType
        pathPrefix = if visType == 'InternalVisualizer'
                visPaths.internalVisualizersPath
            else if visType == 'LunaVisualizer'
                visPaths.lunaVisualizersPath
            else visPaths.projectVisualizersPath
        if pathPrefix?
            url = path.join pathPrefix, @currentVisualizer.visualizerPath
            iframe.name         = @iframeId
            iframe.style.width  = @width + 'px'
            iframe.style.height = @height + 'px'
            iframe.className    = style.luna ['visualization-iframe']
            iframe.src          = url
        return iframe


export class VisualizerMenu extends Widget
    constructor: (args...) ->
        super args...
        @configure
            height: shape.height
            width:  shape.width

    updateModel: ({ key:                @key                = @key
                  , mode:                mode               = @mode
                  , visualizers:         visualizers        = @visualizers
                  , visualizer:          visualizer         = @visualizer
                  , position:            position           = @position or [0,0] }) =>
        if @position != position or @mode != mode or not _.isEqual(@visualizer, visualizer) or not _.isEqual(@visualizers, visualizers)
            @mode              = mode
            @position          = position
            @visualizers       = visualizers
            @visualizer        = visualizer

        unless @def?
            root              = document.createElement 'div'
            root.id           = @key
            @def = basegl.symbol root
        if @view?
            @reattach()

    updateView: =>
        @group.position.xy = [@position[0] + @width/2, @position[1]]
        @view.domElement.innerHTML = '▾'
        @view.domElement.className = style.luna ['dropdown']
        @view.domElement.appendChild @renderVisualizerMenu()

    withNodeKey: (fun) =>
        @parent.withNodeKey(fun)

    eventPathh: =>
        @withNodeKey (nodeKey) =>
            nodeVisPath = @parent.parent.eventPath()
            nodeVisPath.push nodeKey
            nodeVisPath.push "Visualization"
            nodeVisPath.push @key
            nodeVisPath


    pushSelectVisualizer: (visId) => 
        path = @eventPathh()
        base = {
            tag: 'SelectVisualizerEvent'
            visualizerId: visId
        }
        pushEvent path, base, @eventKey()

    renderVisualizerMenu: =>
        menu = document.createElement 'ul'
        menu.className = style.luna ['dropdown__menu']

        @visualizers.forEach (visualizer) =>
            entry = document.createElement 'li'
            if _.isEqual(visualizer, @visualizer)
                entry.className = style.luna ['dropdown__active']
            entry.addEventListener 'mouseup', => @pushSelectVisualizer visualizer
            entry.appendChild (document.createTextNode visualizer.visualizerName)
            menu.appendChild entry

        return menu
