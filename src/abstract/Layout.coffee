import {Widget}       from 'widget/Widget'
import {lookupWidget} from 'widget/WidgetDirectory'


export class Layout extends Widget
    forEach: (fun) =>
        for own key, def of @__defs
            fun def, key

export class FlatLayout extends Layout
    initModel: =>
        s = super()
        s.key = null
        s.children = []
        s.height = null
        s.width = null
        s.offset = 3
        s

    update: =>
        if Object.keys(@__defs).length != @model.children.length
            @deleteDefs()

        for own k, widget of @model.children
            cons = lookupWidget widget
            if cons?
                @autoUpdateDef k, cons, widget
        @__updateChildren()
