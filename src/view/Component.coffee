import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {group}                  from 'basegl/display/Symbol'
import {fieldMixin}             from "basegl/object/Property"
import {Disposable}             from "view/Disposable"

eventListeners = []

export subscribeEvents = (listener) =>
    eventListeners.push listener

export pushEvent = (path, base, key) =>
    unless base.tag? then base.tag = base.constructor.name
    for listener in eventListeners
        listener path, base, key

export class Component extends Disposable
    cons: (values, @parent) ->
        super()
        @mixin eventDispatcherMixin, @
        @propertyListeners = {}
        @set values

    withScene: (fun) => @parent.withScene fun if @parent?

    eventPath: =>
        path = if @parent?
                    @parent.eventPath?() or [@parent.constructor.name]
               else []
        path.push @constructor.name
        path

    eventKey: =>
        key = @parent?.eventKey?() or []
        key.push @key if @key?
        key

    pushEvent: (e) => pushEvent @eventPath(), e, @eventKey()

    redraw: => @set @

    set: (values) =>
        @updateModel values
        @withScene =>
            if @view?
                @updateView()

    attach: => @withScene (scene) =>
        if @def?
            if @def instanceof Array
                @view = {}
                views = []
                for def in @def
                    @view[def.name] = scene.add def.def
                    views.push @view[def.name]
                @group = group views
            else
                @view = scene.add @def
                @group = group [@view]
            @updateView()
        @registerEvents?()

    _detach: => @withScene (scene) =>
        if @view?
            if @def instanceof Array
                for def in @def
                    @view[def.name].dispose() if @view[def.name]?
            else
                @view.dispose()
            @view = null

    reattach: =>
        @_detach()
        @attach()

    emitProperty: (name, property) =>
        unless @[name] == property
            @[name] = property
            propertyEvent = new CustomEvent name, value: property
            @dispatchEvent propertyEvent if @dispatchEvent?

    destruct: => @_detach()
