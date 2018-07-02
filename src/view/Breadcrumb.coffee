import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape}          from 'shape/Html'
import * as style           from 'style'


breadcrumbId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

export class Breadcrumb extends ContainerComponent
    initModel: =>
        moduleName: null
        items: []

    prepare: =>
        @addDef 'root', new HtmlShape
                element: 'div'
                id: breadcrumbId
                scalable: false
            , @

    update: =>
        if @changed.once or @changed.items or @changed.moduleName
            @def('root').__element.domElement.innerHTML = ''
            container = document.createElement 'div'
            container.className = style.luna ['breadcrumbs', 'noselect']
            @model.items[0] =
                name: @model.moduleName or nullModuleNameError
                link: @model.moduleName?
            @model.items.forEach (item) =>
                container.appendChild @__renderItem item
            @def('root').__element.domElement.appendChild container

    adjust: (view) =>
        if @changed.once
            @withScene (scene) =>
                view.position.y = scene.height

    __renderItem: (item) =>
        item.link ?= item.breadcrumb?
        div = document.createElement 'div'
        div.className = style.luna ['breadcrumbs__item', 'breadcrumbs__item--home']
        div.innerHTML = item.name
        if item.link
            div.addEventListener 'click', => @pushEvent
                tag: 'NavigateEvent'
                to: item.breadcrumb
        return div
