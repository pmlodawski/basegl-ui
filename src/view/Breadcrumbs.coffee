import {Component}    from 'view/Component'
import * as basegl from 'basegl'
import * as style  from 'style'


breadcrumbsId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

export class Breadcrumbs extends Component
    updateModel: ({ moduleName: @moduleName = @moduleName
                  , items:      @items      = @items or []
                  , position:   @position   = @position or [0,0]
                  }) =>
        unless @def?
            root = document.createElement 'div'
            root.id = breadcrumbsId
            @def = basegl.symbol root

    updateView: =>
        @view.domElement.innerHTML = ''
        container = document.createElement 'div'
        container.className = style.luna ['breadcrumbs', 'noselect']
        container.appendChild @renderItem (@moduleName or nullModuleNameError)
        @items.forEach (item) =>
            container.appendChild @renderItem item
        @view.domElement.appendChild container

    renderItem: (item) =>
        div = document.createElement 'div'
        div.className = style.luna ['breadcrumbs__item', 'breadcrumbs__item--home']
        div.innerHTML = item
        return div


    getPosition: (scene) =>
        campos = scene.camera.position
        return [ (campos.x + scene.width  / 2) / campos.z - scene.width/2
               , (campos.y + scene.height / 2) / campos.z + scene.height/2]

    align: (position, scale) =>
        if position != @position or scale != @scale
            @position = position
            @scale = scale
            @view.position.xy = @position.slice()
            @group.scale.xy = [@scale, @scale]

    registerEvents: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                @align @getPosition(scene), scene.camera.position.z
