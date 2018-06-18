import {EventEmitter}           from "view/EventEmitter"
import * as _ from 'underscore'


export class HasModel extends EventEmitter
    cons: (values, @parent) =>
        super()

    init: (values) =>
        super()
        @model = @initModel?() or {}
        @changed = {}
        @prepare?()
        @withScene =>
            @set values
            @connectSources?()

    withScene: (fun) => @parent.withScene fun if @parent?

    set: (values) =>
        return unless values?
        for own key of @changed
            @changed[key] = false
        for own key of @model
            if values[key]? and not _.isEqual @model[key], values[key]
                @changed[key] = true
                @model[key] = values[key]
                @performEmit key, values[key]
        @onModelUpdate values
