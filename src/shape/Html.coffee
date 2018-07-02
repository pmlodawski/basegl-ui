import * as util         from 'shape/util'
import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'
        top: true
        scalable: true

    redefineRequired: =>
        @changed.id or @changed.element

    define: =>
        root = document.createElement @model.element
        root.id = @model.id if @model.id?
        basegl.symbol root

    adjust: =>
        if @changed.top or @changed.scalable
            if @model.top and @model.scalable
                @root.topDomScene.model.add @__element.obj
            else if @model.top
                @root.topDomSceneNoScale.model.add @__element.obj
                @__forceUpdatePosition()
            else
                @root.scene.domModel.model.add @view.obj

    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        if @__element?
            if @__element.position.y == 0
                @__element.position.y = 1
            else
                @__element.position.y = 0
