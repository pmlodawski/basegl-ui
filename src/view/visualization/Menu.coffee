import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerButton} from 'shape/visualization/Button'
import {TextContainer}    from 'view/Text'
import {VerticalLayout} from 'widget/VerticalLayout'

export class VisualizerMenu extends ContainerComponent
    initModel: =>
        key : null
        mode : null
        visualizers : null
        visualizer : null
        position : [0, 0]

    prepare: =>
        @addDef 'button', new VisualizerButton null, @
        @addDef 'menu', new VerticalLayout
                # width: 400
                children:
                    [
                        cons: TextContainer
                        text: 'test'
                    ,
                        cons: TextContainer
                        text: 'a'
                    ,
                        cons: TextContainer
                        text: 'very long text'
                    ]
            , @



# export class VisualizerMenu extends ContainerComponent
#     initModel: =>
#         key : null
#         mode : null
#         visualizers : null
#         visualizer : null
#         position : [0, 0]

#     prepare: =>
#         @addDef 'root', new HtmlShape element: 'div', @

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
