import {ContainerComponent} from 'abstract/ContainerComponent'
import {Slider}             from 'widget/Slider'


export class HorizontalLayout extends ContainerComponent
    initModel: =>
        widgets: []
        width: 100

    update: =>
        if @changed.widgets
            for own k, widget of @model.widgets
                @autoUpdateDef k, Slider, widget

        return unless @model.widgets.length > 0
        ws = []
        minWidth = 0
        startPoint = [0,0]
        for i in [0..@model.widgets.length - 1]
            ws.push
                index  : i
                widget : @model.widgets[i]
                width : @def(i).model.minWidth
            minWidth += @def(i).model.minWidth
            @updateDef i, siblings:
                left:  ! (i == 0)
                right: ! (i == @model.widgets.length - 1)
        offset = 3
        free = @model.width - minWidth - offset * (@model.widgets.length - 1)
        ws.sort (a, b) -> a.widget.maxWidth - b.widget.maxWidth
        for i in [0..ws.length - 1]
            w = ws[i]
            wfree = free / (ws.length - i)
            if (! w.widget.maxWidth?) or w.widget.maxWidth > w.width + wfree
                free -= wfree
                w.width += wfree
            else
                free -= w.widget.maxWidth - w.width
                w.width = w.widget.maxWidth
        ws.forEach (w) =>
            @view(w.index).position.xy = startPoint.slice()
            @updateDef w.index, width: w.width
            startPoint[0] += w.width + offset
