import * as path         from 'path'

import * as style                from 'style'
import {Widget}                  from 'widget/Widget'
import {HtmlShape}               from 'shape/Html'
import {ModuleShape}             from 'shape/node/Module'
import * as menuShape            from 'shape/visualization/Button'
import {VisualizationCoverShape} from 'shape/visualization/Cover'
import {VisualizationIFrame}     from 'view/visualization/IFrame'
import {VisualizerMenu}          from 'view/visualization/Menu'

iframeYOffset = 5

export class Visualization extends Widget
    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: null

    prepare: =>
        @addDef 'menu', VisualizerMenu
        @addDef 'cover', VisualizationCoverShape
        @addDef 'iframe', VisualizationIFrame
        @addDef 'background', ModuleShape,
            height: @style.visualization_height
            width: @style.visualization_width

    update: =>
        if @changed.currentVisualizer or @changed.iframeId or @changed.mode
            @updateDef 'iframe',
                iframeId: @model.iframeId
                currentVisualizer: @model.currentVisualizer
                mode: @model.mode
        if @changed.currentVisualizer
            @updateDef 'menu',
                selected: @model.currentVisualizer.visualizerId

    adjust: =>
        if @changed.once
            @view('menu').position.xy = [ @style.visualization_menuX, @style.visualization_menuY]

    connectSources: =>
        updateMenu = => @updateDef 'menu',
            visualizers: @parent.parent.model.visualizers
        updateMenu()
        @addDisposableListener @parent.parent, 'visualizers', updateMenu

    registerEvents: =>
        @view('cover').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'FocusVisualizationEvent'
