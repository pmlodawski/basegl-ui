import {Composable}             from "basegl/object/Property"


export class Disposable extends Composable
    cons: =>
        @disposables = []
        @disposed = false

    dispose: =>
        @fireDisposables()
        @destruct?()
        @disposed = true

    addDisposableListener: (target, name, handler) =>
        console.log "addDisposableListener", @constructor.name, name
        target.addEventListener name, handler
        @onDispose => console.log "DUPA"; target.removeEventListener name, handler

    onDispose: (finalizer) =>
        @disposables.push finalizer

    fireDisposables: =>
        @disposables.forEach (disposable) =>
            disposable()
        @disposables = []