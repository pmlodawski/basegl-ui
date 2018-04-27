import {Composable}             from "basegl/object/Property"


export class Disposable extends Composable
    cons: =>
        @disposables = []

    dispose: =>
        @disposables.forEach (disposable) =>
            disposable()
        @destruct?()

    addDisposableListener: (target, name, handler) =>
        target.addEventListener name, handler
        @onDispose => target.removeEventListener name, handler

    onDispose: (finalizer) =>
        @disposables.push finalizer
