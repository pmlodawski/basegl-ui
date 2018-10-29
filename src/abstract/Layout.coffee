import {Widget}       from 'widget/Widget'
import {lookupWidget} from 'widget/WidgetDirectory'


export class Layout extends Widget
    forEach: (fun) =>
        i = 0
        for own k, child of @model.children
            key = @__childKey child, k
            fun @def(key), key, i++

    __childKey: (child, key) => child.id or child.key or key

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
        newDefs = {}
        for own k, widget of @model.children
            key = @__childKey widget, k
            newDefs[key] = widget
        for own key, def of @__defs
            unless newDefs[key]?
                @deleteDef key
        for own key, widget of newDefs
            cons = lookupWidget widget
            if cons?
                @autoUpdateDef key, cons, widget
        @__updateChildren()
