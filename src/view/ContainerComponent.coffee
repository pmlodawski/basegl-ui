import {EventEmitter} from "view/EventEmitter"
import {HasModel}     from "view/HasModel"

import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'


export class ContainerComponent extends HasModel
    # __defs: { key -> Component }
    # __view: group

    cons: (values, @parent) =>
        super()
        @__defs = {}
        @prepare()
        @set values
        @connectSources()

    destruct: =>
        for def in @__defs
            def.dispose()

    onModelUpdate: =>
        @update()
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

    # # implement this when deriving: #
    # #################################
    #
    # prepare: =>
    #     # called once, define @model
    #
    # update: (values) =>
    #     # update defs using @def, @addDef, @deleteDef
    #
    # registerEvents: (element) =>
    #     # register events on element being group of all defs
