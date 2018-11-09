import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {Disposable}             from "abstract/Disposable"

export class PropertyEmitter extends Disposable
    cons: ->
        super()
        @mixin eventDispatcherMixin, @

    emitProperty: (name, property) =>
        unless @[name] == property
            @[name] = property
            @performEmit name, property

    performEmit: (name, property) =>
        propertyEvent = new CustomEvent name, detail: property
        @dispatchEvent propertyEvent #if @dispatchEvent?
