import {Widget}       from 'widget/Widget'


export class SetView extends Widget
    initModel: =>
        model = super()
        model.elems = {}
        model.cons = null
        model

    update: =>
        if @changed.cons
            @deleteDefs()
        if @changed.elems
            for own key of @__defs
                unless @model.elems[key]?
                    @deleteDef key
            for k, elem of @model.elems
                @autoUpdateDef k, @model.cons, elem

