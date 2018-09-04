import * as path         from 'path'

import * as style           from 'style'
import {HtmlShapeWithScene} from 'shape/Html'
import {ContainerComponent} from 'abstract/ContainerComponent'

width = 300
height = 300

export class VisualizationIFrame extends ContainerComponent
    @ctr = 0

    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: 'Default' # Default|Focused|Preview

    prepare: =>
        id = 'iframe-containter-' + VisualizationIFrame.ctr
        VisualizationIFrame.ctr += 1
        @addDef 'root', HtmlShapeWithScene,
            id: id
            element: 'div'
            clickable: false

        @html = @def('root')
        @sceneId = "basegl-root-layer-" + @html.sceneId
        @scene   = document.getElementById(@sceneId)

    __isModeDefault: => @model.mode == 'Default'
    __isModeFocused: => @model.mode == 'Focused'
    __isModePreview: => @model.mode == 'Preview'

    __width: =>
        if @__isModePreview() then @root._scene.width - 10  else width

    __height: =>
        if @__isModePreview() then @root._scene.height - 10 else height

    update: =>
        if @changed.mode
            console.log "NEW MODE: ", @model.mode
            if @model.mode == 'Preview'
                @html.makeStill()
            else
                @html.makeMovable()
            # @updateDef 'root',
            #     clickable: not @__isModeDefault()
            #     top: not @__isModeDefault()
            #     scalable: not @__isModePreview()
            #     still: @__isModePreview()
        if @changed.iframeId
            @updateDef 'root',
                id: @model.iframeId


        if @changed.currentVisualizer
            @iframe = @__mkIframe()
            if @iframe?
                domElem = @html.getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild @iframe
        if @changed.iframeId
            @iframe?.name = @model.iframeId
        @iframe?.style.width  = @__width() + 'px'
        @iframe?.style.height = @__height() + 'px'

    adjust: (view) =>
        if @changed.mode
            console.log "@width: #{@__width()}, @height: #{@__height()}"
            if @__isModeDefault()
                @scene.style.zIndex = 0
                # @html.__addToGroup @html.__element
                window.visElement = @html.__element
                window.rootElement = @view('root')
                @html.__element.position.xy = [width/2, -height/2]
            else if @__isModeFocused()
                @scene.style.zIndex = 10
                @html.__element.position.xy = [width/2, -height/2]
            else if @__isModePreview()
                @scene.style.zIndex = 10
                @html.__element.position.xy = [0, 0]
                # @html.__addToGroup @html.__element
                # @html.__element.position.xy = [0,0]

        console.log "Root position: ", @view('root').position.xy
        console.log "StillCamera position: ", @html.stillCamera.position

    __mkIframe: =>
        if @model.currentVisualizer?
            visPaths = @root.visualizerLibraries
            visType = @model.currentVisualizer.visualizerId.visualizerType
            pathPrefix = if visType == 'InternalVisualizer'
                    visPaths.internalVisualizersPath
                else if visType == 'LunaVisualizer'
                    visPaths.lunaVisualizersPath
                else visPaths.projectVisualizersPath

        if pathPrefix?
            url = path.join pathPrefix, @model.currentVisualizer.visualizerPath

        console.log "URL: ", url    
        if url?
            iframe           = document.createElement 'iframe'
            iframe.className = style.luna ['basegl-visualization-iframe']
            iframe.src       = url
            iframe

    registerEvents: (view) =>
        window.addEventListener 'keyup', (event) =>
            if event.key == 'z'
                @set(mode: 'Default')
            if event.key == 'x'
                @set(mode: 'Focused')
            if event.key == 'c'
                @set(mode: 'Preview')
