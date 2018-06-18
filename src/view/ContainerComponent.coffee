import {EventEmitter} from "view/EventEmitter"
import {HasModel}     from "view/HasModel"

import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'


export class ContainerComponent extends HasModel
    # __defs: { key -> Component }
    # __view: group
    cons: (args...) =>
        super args...
        @__defs = {}

    dispose: =>
        for def in @__defs
            def.dispose()
        super()

    onModelUpdate: =>
        @update?()
        if @__defsModified
            shapes = []
            for own key of @__defs
                shapes.push @__defs[key].__view
            @__view = basegl.group shapes
            @__defsModified = false
            @registerEvents? @__view

    view: (key) => @def(key).__view

    def: (key) => @__defs[key]

    addDef: (key, def) =>
        unless @__defs[key]?
            @__defs[key] = def
            @__defsModified = true
        else unless _.isEqual @__defs[key], def
            @__defs[key].dispose()
            @__defs[key] = def
            @__defsModified = true

    deleteDef: (key) =>
        if @__defs[key]?
            @__defs[key].dispose()
            delete @__defs[key]
            @__defsModified = true

    # # implement following methods when deriving: #
    # ##############################################
    #
    # initModel: =>
    #     # return model structure (optional, default: {})
    #
    # prepare: =>
    #     # called once, add initial defs here (optional)
    #
    # redefineRequred (values) =>
    #     # test values if it is required to redefine shape (optional, default: false)
    #
    # update: (values) =>
    #     # update defs using @def, @addDef, @deleteDef (optional)
    #
    # registerEvents: (element) =>
    #     # register events on element being group of all defs (optional)
