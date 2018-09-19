import {FlatLayout} from 'abstract/Layout'


export class HorizontalLayout extends FlatLayout
    __updateChildren: =>
        return unless @model.children.length > 0
        children = []
        @__minWidth = 0
        @__maxWidth = 0
        @__minHeight = 0
        @__maxHeight = Infinity
        @forEach (def, key, i) =>
            children.push
                key    : key
                index  : i
                widget : def
                width  : def.minWidth()
            @__minWidth += def.minWidth() or 0
            @__maxWidth += def.maxWidth() or 0
            @__minHeight = Math.max def.minHeight(), @__minHeight
            @__maxHeight = Math.min def.maxHeight(), @__maxHeight
            @updateDef key, siblings:
                left:  ! (i == 0)
                right: ! (i == @model.children.length - 1)
        if @model.width?
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

        startPoint = [0,0]
        children.forEach (w) =>
            @view(w.key).position.xy = startPoint.slice()
            @updateDef w.key,
                width: w.width
                height: @__computeHeight w.widget
            startPoint[0] += w.width + @model.offset

    __computeHeight: (widget) =>
        height = @model.height or @minHeight()
        if height < widget.maxHeight()
            height
        else
            widget.maxHeight()
