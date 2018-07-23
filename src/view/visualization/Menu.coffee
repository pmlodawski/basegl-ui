import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerButton}   from 'shape/visualization/Button'
import {TextContainer}      from 'view/Text'
import {VerticalLayout}     from 'widget/VerticalLayout'

export class VisualizerMenu extends ContainerComponent
    initModel: =>
        visualizers : null
        menuVisible: false

    prepare: =>
        @addDef 'button', VisualizerButton, null

    update: =>
        if @changed.menuVisible or @changed.visualizers
            children = []
            if @model.visualizers?
                for visualizer in @model.visualizers
                    children.push
                        cons: TextContainer
                        text: visualizer.visualizerName
                        align: 'right'
                @autoUpdateDef 'list', VerticalLayout, if @model.menuVisible
                    children: children
    adjust: =>
        @view('list')?.position.xy = [10, -15]

    registerEvents: =>
        @view('button').addEventListener 'mousedown', =>
            @set menuVisible: not @model.menuVisible

# export class VisualizerMenu extends ContainerComponent
#     initModel: =>
#         key : null
#         mode : null
#         visualizers : null
#         visualizer : null
#         position : [0, 0]

#     prepare: =>
#         @addDef 'root', HtmlShape, element: 'div'

#     update: =>
#         if @changed.visualizer or @changed.visualizers
#             @updateMenu()

#         if @changed.mode
#             @__updateMode()

#     __updateMode: =>
#         if @model.mode == 'Default'
#             @view('root').domElement.className = style.luna ['basegl-dropdown']
#             @menu?.className = style.luna ['basegl-dropdown__menu']
#             @updateDef 'root',
#                 top:   false
#                 still: false
#         else if @model.mode == 'Focused'
#             @view('root').domElement.className = style.luna ['basegl-dropdown--top']
#             @menu?.className = style.luna ['basegl-dropdown__menu']
#             @updateDef 'root',
#                 top:   true
#                 still: false
#         else
#             @view('root').domElement.className = style.luna ['basegl-dropdown--fullscreen']
#             @menu?.className = style.luna ['basegl-dropdown__menu--fullscreen']
#             @updateDef 'root',
#                 top:   true
#                 still: true

#     updateMenu: =>
#         @menu?.parentNode.removeChild @menu
#         delete @menu
#         @menu = @renderVisualizerMenu()
#         @view('root').domElement.appendChild @menu

#     renderVisualizerMenu: =>
#         menu = document.createElement 'ul'
#         @model.visualizers.forEach (visualizer) =>
#             entry = document.createElement 'li'
#             if _.isEqual(visualizer, @model.visualizer)
#                 entry.className = style.luna ['basegl-dropdown__active']
#             entry.addEventListener 'mouseup', => @pushEvent
#                 tag: 'SelectVisualizerEvent'
#                 visualizerId: visualizer
#             entry.appendChild (document.createTextNode visualizer.visualizerName)
#             menu.appendChild entry

#         return menu
