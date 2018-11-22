import {ContainerComponent} from 'abstract/ContainerComponent'
import {SetView}            from 'widget/SetView'


export class Port extends ContainerComponent
    prepare: =>
        @addDef 'subports', SetView, cons: @portConstructor()

    follow: (key, angle) =>
        subports = Object.assign {}, @model.subports
        subports[key] = angle
        @set subports: subports

    unfollow: (key) =>
        subports = Object.assign {}, @model.subports
        delete subports[key]
        @set subports: subports

export defaultColor = [43/256, 101/256, 251/256]
