import {ContainerComponent} from 'abstract/ContainerComponent'
import {lookupWidget}       from 'widget/WidgetDirectory'


export class HorizontalLayout extends ContainerComponent
    initModel: =>
        widgets: []
        width: null
        height: null
        offset: 3

    update: =>
        if @changed.widgets
            for own k, widget of @model.widgets
                cons = lookupWidget widget
                if cons?
                    @autoUpdateDef k, cons, widget

        return unless @model.widgets.length > 0
        widgets = []
        minWidth = 0
        startPoint = [0,0]
        for i in [0..@model.widgets.length - 1]
            widgets.push
                index  : i
                widget : @def(i).model
                width : @def(i).model.minWidth
            minWidth += @def(i).model.minWidth or 0
            @updateDef i, siblings:
                left:  ! (i == 0)
                right: ! (i == @model.widgets.length - 1)
        free = @model.width - minWidth - @model.offset * (@model.widgets.length - 1)
        widgets.sort (a, b) -> a.widget.maxWidth - b.widget.maxWidth
        for i in [0..widgets.length - 1]
            w = widgets[i]
            wfree = free / (widgets.length - i)
            if (! w.widget.maxWidth?) or w.widget.maxWidth > w.width + wfree
                free -= wfree
                w.width += wfree
            else
                free -= w.widget.maxWidth - w.width
                w.width = w.widget.maxWidth
        widgets.sort (a, b) -> a.index - b.index
        widgets.forEach (w) =>
            @view(w.index).position.xy = startPoint.slice()
            @updateDef w.index,
                width: w.width
                height: @__computeHeight w.widget
            startPoint[0] += w.width + @model.offset

    __computeHeight: (widget) =>
        if @model.height < widget.maxHeight
            @model.height
        else
            widget.maxHeight
