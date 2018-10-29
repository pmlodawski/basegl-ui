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
        performDispose = =>
            for own k, def of @__defs
                def.dispose()
            super()

        if @adjustDst?
            @adjustDst @__view
            setTimeout performDispose, 1000 * @style.transform_time
        else
            @adjustSrc? @__view
            performDispose()

    onModelUpdate: =>
        @update?()
        if @changed.once
            @adjustSrc? @__view
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
            @__addToGroup @__defs[key].__view
            @__defs[key].dispose()
            @__addToGroup def.__view
            @__defs[key] = def

    deleteDef: (key) =>
        if @__defs[key]?
            @__addToGroup @__defs[key].__view
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

    setPosition: (target, value, animate = true) =>
        @setPositionX target, value[0], animate
        @setPositionY target, value[1], animate

    setPositionX: (target, value, animate = true) =>
        if target?
            if animate
                animation.animate @style, target, 'position', 'x', value
            else
                target.position.x = value

    setPositionY: (target, value, animate = true) =>
        if target?
            if animate
                animation.animate @style, target, 'position', 'y', value
            else
                target.position.y = value

    setRotation: (target, value, animate = true) =>
        if target?
            if animate
                animation.animate @style, target, 'rotation', 'z', value
            else
                target.rotation.z = value

    setScale: (target, value, animate = true) =>
        @setScaleX target, value[0], animate
        @setScaleY target, value[1], animate

    setScaleX: (target, value, animate = true) =>
        if target?
            if animate
                animation.animate @style, target, 'scale', 'x', value
            else
                target.scale.x = value

    setScaleY: (target, value, animate = true) =>
        if target?
            if animate
                animation.animate @style, target, 'scale', 'y', value
            else
                target.scale.y = value

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
