import {EventEmitter} from "abstract/EventEmitter"
import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'

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

    init: (values) =>
        super()
        @__view = basegl.group []
        @model = @initModel?() or {}
        @changed = {}
        @withScene =>
            @__setValues values
            @changed.once = true
            @prepare?()
            @onModelUpdate values
            @connectSources?()
            @registerEvents? @__view
            @changed.once = false

    withScene: (fun) => @parent.withScene fun if @parent?

    set: (values) =>
        @withScene =>
            @__setValues values
            @onModelUpdate values

    __setValues: (values, once = false) =>
        if values?
            for own key of @model
                @changed[key] = false
                value = unArray @model[key], values[key]
                if value? and not _.isEqual @model[key], value
                    @changed[key] = true
                    @model[key] = value
                    @performEmit key, value

    __addToGroup:      (view) =>
        @__view.addChild view
        @__view.updateChildrenOrigin()

    __removeFromGroup: (view) =>
        @__view.removeChild view
        @__view.updateChildrenOrigin()
