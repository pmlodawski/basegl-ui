import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'

import {EventEmitter} from "abstract/EventEmitter"
import {HasModel}     from "abstract/HasModel"
import * as animation from 'shape/Animation'


export class ContainerComponent extends HasModel
    # __defs: { key -> Component }
    # __view: group
    cons: (args...) =>
        super args...
        @__defs = {}

    dispose: =>
        for own k, def of @__defs
            def.dispose()
        super()

    onModelUpdate: =>
        @update?()
        @adjust? @__view

    view: (key) => @def(key)?.__view

    def: (key) => @__defs[key]

    updateDef: (key, value) =>
        @def(key).set value

    addDef: (key, cons, value) =>
        def = new cons value, @
        unless @__defs[key]?
            @__defs[key] = def
            @__addToGroup def.__view
        else unless _.isEqual @__defs[key], def
            @__removeFromGroup @__defs[key].__view
            @__defs[key].dispose()
            @__addToGroup def.__view
            @__defs[key] = def

    deleteDef: (key) =>
        if @__defs[key]?
            @__removeFromGroup @__defs[key].__view
            @__defs[key].dispose()
            delete @__defs[key]

    autoUpdateDef: (key, cons, value) =>
        if @def(key)? and @def(key).constructor != cons
            @deleteDef key
        if @def(key)?
            if value?
                @updateDef key, value
            else
                @deleteDef key
        else if value?
            @addDef key, cons, value

    deleteDefs: =>
        for own k of @__defs
            @deleteDef k

    animatePosition: (target, value) =>
        if target?
            @animatePositionX target, value[0]
            @animatePositionY target, value[1]

    animatePositionX: (target, value) =>
        if target?
            animation.animate @style, target, 'position', 'x', value

    animatePositionY: (target, value) =>
        if target?
            animation.animate @style, target, 'position', 'y', value

    animateRotation: (target, value) =>
        if target?
            animation.animate @style, target, 'rotation', 'z', value

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
