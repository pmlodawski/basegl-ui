import * as path      from 'path'
import * as _         from 'underscore'
import * as basegl    from 'basegl'
import * as style     from 'style'
import * as nodeShape from 'shape/Node'
import * as shape     from 'shape/Visualization'

import {group}                from 'basegl/display/Symbol'
import {Component, pushEvent} from 'view/Component'
import {Widget}               from 'view/Widget'


export visualizationCoverShape = basegl.symbol shape.visualizationCover


export class NodeVisualizations extends Component
    cons: (values, @parent) =>
        @nodeEditor = @parent
        super values, @parent

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

            for own key of @visualizations
                unless newVisualizations[key]?
                    @visualizations[key].dispose()

            @visualizations = newVisualizations

    dispose: =>
        for own k,v of @visualizations
           v.dispose()

    getPosition: =>
        node = @nodeEditor.node @nodeKey
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
        node = @nodeEditor.node @nodeKey
        @addDisposableListener node, 'position', => @updateVisualizationsPositions()
        @addDisposableListener node, 'expanded', => @updateVisualizationsPositions()

    eventPath: =>
        nePath = @nodeEditor.eventPath?() or [@nodeEditor.constructor.name]
        nePath.concat ["NodeVisualization", @nodeKey]

export class VisualizationContainer extends Widget
    cons: (values, @parent) =>
        @nodeEditor = @parent.nodeEditor
        @def        = visualizationCoverShape
        @configure
            height: shape.height
            width:  shape.width
        super values, @parent

    updateModel: ({ key:                @key                = @key
                  , iframeId:            iframeId           = @iframeId
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , selectedVisualizer:  selectedVisualizer = @selectedVisualizer
                  , visualizers:         visualizers        = @visualizers
                  , position:            position           = @position or [0,0] }) =>
        @position           = position
        @iframeId           = iframeId
        @mode               = mode
        @currentVisualizer  = currentVisualizer
        @selectedVisualizer = selectedVisualizer
        @visualizers        = visualizers

        unless @view?
            @attach()

        @updateVisualization()
        @updateVisualizerMenu()


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
        else @visualizerMenu?.dispose()

    updateView: =>
        @group.position.xy = [ 
            @position[0] - shape.width/2,
            @position[1] - @height ]
        @view.bbox.xy = [shape.width, @height]

    dispose: =>
        super()
        @visualization?.dispose()
        @visualizerMenu?.dispose()
    
    eventPath: =>
        evtPath = @parent.eventPath()
        evtPath.push @key
        evtPath

    pushFocusVisualization: => 
        base = {
            tag: 'FocusVisualizationEvent'
        }
        pushEvent @eventPath(), base

    registerEvents: =>
        @group.addEventListener 'click', =>
            if @mode == 'Default'
                @pushFocusVisualization()

export class Visualization extends Widget
    cons: (values, @parent) =>
        @nodeEditor  = @parent.nodeEditor
        @eventPath   = @parent.eventPath
        @configure
            height: @parent.height
            width:  @parent.width
        super values, @parent
        @registerEvents()
    
    registerEvents: =>
        @addDisposableListener @nodeEditor, 'visualizerLibraries', => @reattach()

    updateModel: ({ key:                @key                = @key
                  , iframeId:            iframeId           = @iframeId
                  , mode:                mode               = @mode
                  , currentVisualizer:   currentVisualizer  = @currentVisualizer
                  , position:            position           = @position or [0,0] }) =>
        @position = position

        if @mode != mode
            @mode = mode
            # @softReattach() # TODO: UNCOMMENT THIS LINE WHEN IFRAME REPLACED WITH SHADOW DOM

        if @iframeId != iframeId or
        not _.isEqual(@currentVisualizer, currentVisualizer)
            @iframeId          = iframeId
            @currentVisualizer = currentVisualizer
            @reattach()

        unless @view?
            @attach()
    
    softReattach: => @withScene (scene) =>
        if @view?
            if @mode == 'Default'
                @view.domElement.style.pointerEvents            = 'none'
                @view.domElement.firstChild.style.pointerEvents = 'none'
                scene.domModel.model.add @view.obj
            else
                @view.domElement.style.pointerEvents            = 'auto'
                @view.domElement.firstChild.style.pointerEvents = 'auto'
                @nodeEditor.topDomScene.model.add @view.obj

    updateView: =>
        @group?.position.xy = [@position[0], @position[1] - @height/2]

    attach: => @withScene =>
        iframe = @__mkIframe()
        if iframe?
            vis              = document.createElement 'div'
            vis.id           = @key
            vis.style.width  = @width + 'px'
            vis.style.height = @height + 'px'
            vis.appendChild iframe
            visSymbol = basegl.symbol vis

            @view  = visSymbol.newInstance()
            @group = group [@view]
        
        @softReattach()
        @updateView()

    __mkIframe: =>
        if @currentVisualizer?
            visPaths = @nodeEditor.visualizerLibraries
            visType = @currentVisualizer.visualizerId.visualizerType
            pathPrefix = if visType == 'InternalVisualizer'
                    visPaths.internalVisualizersPath
                else if visType == 'LunaVisualizer'
                    visPaths.lunaVisualizersPath
                else visPaths.projectVisualizersPath
        
        if pathPrefix?
            url = path.join pathPrefix, @currentVisualizer.visualizerPath
                
        if url?
            iframe              = document.createElement 'iframe'
            iframe.name         = @iframeId
            iframe.style.width  = @width + 'px'
            iframe.style.height = @height + 'px'
            iframe.src          = url
            iframe


export class VisualizerMenu extends Widget
    cons: (values, @parent) =>
        @nodeEditor  = @parent.nodeEditor
        @eventPath   = @parent.eventPath
        @configure
            height: @parent.height
            width:  @parent.width
        super values, @parent

    updateModel: ({ key:                @key                = @key
                  , mode:                mode               = @mode
                  , visualizers:         visualizers        = @visualizers
                  , visualizer:          visualizer         = @visualizer
                  , position:            position           = @position or [0,0] }) =>
        unless @def?
            root           = document.createElement 'div'
            root.id        = @key
            root.innerHTML = '▾'
            root.className = style.luna ['dropdown']
            @def    = basegl.symbol root
            
        if @position != position or @mode = mode
            @mode      = mode
            @position  = position

        if not _.isEqual(@visualizer, visualizer) or
        not _.isEqual(@visualizers, visualizers)
            @visualizers = visualizers
            @visualizer  = visualizer
            menuChanged  = true

        if @view?
            if menuChanged
                @updateMenu()
            else @updateView()
        else @attach()

    updateMenu: =>
        if @view?
            @menu?.parentNode.removeChild @menu
            delete @menu
            @menu = @renderVisualizerMenu()
            @view.domElement.appendChild @menu
            @updateView()

    attach: => @withScene (scene) =>
        super()
        @updateMenu()

    updateView: =>
        @group?.position.xy = [@position[0] - @width/2 , @position[1]]

    pushSelectVisualizer: (visId) => 
        path = @eventPath()
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
