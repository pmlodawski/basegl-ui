import {HasModel}        from "abstract/HasModel"
import * as basegl       from 'basegl/display/Symbol'
import {animateVariable} from 'shape/Animation'


export class BasicComponent extends HasModel
    __draw: (def) =>
        @withScene (scene) =>
            @__element = scene.add def
            @__addToGroup @__element

    __undraw: =>
        if @__element?
            @__removeFromGroup @__element
            @__element.dispose()
            @__element = null

    onModelUpdate: =>
        if (@redefineRequired? and @redefineRequired(@changed)) or @changed.once
            def = @define()
            if def?
                @__undraw()
                @__draw def
                @__def = def
        if @__element?
            @adjust? @__element, @__view

    dispose: =>
        @__undraw @__def
        if @__view
            @__view.dispose()
            @__view = null
        super()

    getElement: => @__element

    getDomElement: => @getElement()?.domElement

    animateVariable: (name, value) =>
        animateVariable @style, @__element, name, value

    # # implement following methods when deriving: #
    # ##############################################
    #
    # initModel: =>
    #     # return model structure (optional, default: {})
    #
    # prepare: =>
    #     # initialize component (optional)
    #
    # redefineRequired (values) =>
    #     # test values if it is required to redefine shape (optional, default: false)
    #
    # define =>
    #     # use @values to create def and return it
    #     ...
    #     return def
    #
    # registerEvents: (element) =>
    #     # register events on element being group of all defs (optional)
    #
    # adjust (element, view) =>
    #     # use @values to adjust element and view
    #     ...
    #     element.rotation = @values.angle
    #     ...

export memoizedSymbol = (symbolFun) =>
    lastRevision = null
    cachedSymbol = null
    return (style) =>
        unless lastRevision == style.revision
            lastRevision = style.revision
            cachedSymbol = symbolFun style
        return cachedSymbol
