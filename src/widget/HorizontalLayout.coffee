import {ContainerComponent} from 'abstract/ContainerComponent'
import {lookupWidget}       from 'widget/WidgetDirectory'


export class HorizontalLayout extends ContainerComponent
    initModel: =>
        key: null
        children: []
        width: null
        height: null
        offset: 3

    update: =>
        if @changed.children
            for own k, widget of @model.children
                cons = lookupWidget widget
                if cons?
                    @autoUpdateDef k, cons, widget

        return unless @model.children.length > 0
        children = []
        @__minWidth = 0
        @__maxWidth = 0
        @__minHeight = 0
        @__maxHeight = Infinity
        startPoint = [0,0]
        for i in [0..@model.children.length - 1]
            children.push
                index  : i
                widget : @def(i)
                width : @def(i).minWidth()
            @__minWidth += @def(i).minWidth() or 0
            @__maxWidth += @def(i).maxWidth() or 0
            @__minHeight = Math.min @def(i).minHeight(), @__minHeight
            @__maxHeight = Math.max @def(i).maxHeight(), @__maxHeight
            @updateDef i, siblings:
                left:  ! (i == 0)
                right: ! (i == @model.children.length - 1)
        free = @model.width - @__minWidth - @model.offset * (@model.children.length - 1)
        children.sort (a, b) -> a.widget.maxWidth() - b.widget.maxWidth()
        for i in [0..children.length - 1]
            w = children[i]
            wfree = free / (children.length - i)
            if (! w.widget.maxWidth()?) or w.widget.maxWidth() > w.width + wfree
                free -= wfree
                w.width += wfree
            else
                free -= w.widget.maxWidth() - w.width
                w.width = w.widget.maxWidth()
        children.sort (a, b) -> a.index - b.index
        children.forEach (w) =>
            @view(w.index).position.xy = startPoint.slice()
            @updateDef w.index,
                width: w.width
                height: @__computeHeight w.widget
            startPoint[0] += w.width + @model.offset

    __computeHeight: (widget) =>
        height = @model.height
        if height < widget.maxHeight()
            height
        else
            widget.maxHeight()
