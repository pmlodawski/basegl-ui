import {ContainerComponent} from 'abstract/ContainerComponent'


export class Subport extends ContainerComponent
    registerEvents: (view) =>
        view.addEventListener 'mousedown', @pushEvent
        view.addEventListener 'mouseup',  @pushEvent

export class Port extends ContainerComponent
    follow: (key, angle) =>
        subports = Object.assign {}, @model.subports
        subports[key] = angle
        @set subports: subports

    unfollow: (key) =>
        subports = Object.assign {}, @model.subports
        delete subports[key]
        @deleteDef ('sub' + key)
        @set subports: subports

    setCons: (@cons) =>
