import {EventEmitter} from "abstract/EventEmitter"
import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'
import {mat4}         from 'gl-matrix'


unArray = (ref, obj) =>
    if ref? and (not Array.isArray ref) and Array.isArray obj
        ret = {}
        for el in obj
            ret[el.key] = el
        ret
    else
        obj

export class HasModel extends EventEmitter
    cons: (values, @parent) =>
        super()
        @root =  @parent?.root or @parent or @
        @style = @root?.styles?.install @

    init: (values) =>
        super()
        @__view = basegl.group []
        @model = @initModel?() or {}
        @changed = {}
        @__setValues values, true
        @changed.once = true
        @prepare?()
        @onModelUpdate values
        @connectSources?() #TODO check with styles reload
        @registerEvents @__view #TODO check with styles reload
        @changed.once = false


    registerEvents: () -> # to be defined in subclass

    set: (values) =>
        return if @disposed
        @__setValues values
        if @__anythingChanged
            @__updateModel values

    forceReset: =>
        for own key of @model
            @changed[key] = true
        @changed.once = true
        @__updateModel @model

    __updateModel: (values) =>
        @onModelUpdate values
        @performEmit 'modelUpdated', values

    __setValues: (values, once = false) =>
        values ?= {}
        @__anythingChanged = once
        valuesToEmit = {}
        for own key of @model
            @changed[key] = once
            value = unArray @model[key], values[key]
            if value != undefined and not _.isEqual @model[key], value
                @changed[key] = true
                @__anythingChanged = true
                @model[key] = value
                valuesToEmit[key] = value
        for own key, value of valuesToEmit
            @performEmit key, value

    __addToGroup: (view) =>
        @__view.addChild view
        @__view.updateChildrenOrigin() # TODO: remove (basegl bug)

    __removeFromGroup: (view) =>
        @__view.removeChild view
        @__view.updateChildrenOrigin() # TODO: remove (basegl bug)
        # view.setOrigin mat4.create()

    log:  (msg) => console.log  "[#{@constructor.name}]", msg
    warn: (msg) => console.warn "[#{@constructor.name}]", msg
