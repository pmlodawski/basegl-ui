import {EventEmitter}           from "view/EventEmitter"
import * as _ from 'underscore'


export class HasModel extends EventEmitter
    # _defs: { key -> Component }
    # _element: group

    cons: (values) =>
        super()
        @model = {}
        @changed = {}

    set: (values) =>
        return unless values?
        for own key of @changed
            @changed[key] = false
        for own key of @model
            if values[key]? and not _.isEqual @model[key], values[key]
                @changed[key] = true
                @model[key] = values[key]
        @onModelUpdate values
