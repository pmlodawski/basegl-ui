import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort, OutPort} from 'view/Port'
import {Component}       from 'view/Component'
import * as shape        from 'shape/Node'
import * as util         from 'shape/util'

### Utils ###

makeDraggable = (a) ->
    a.group.addEventListener 'mousedown', (e) ->
        if e.button != 0 then return
        s = basegl.world.activeScene
        fmove = (e) ->
            x = a.position[0] + e.movementX * s.camera.zoomFactor
            y = a.position[1] - e.movementY * s.camera.zoomFactor
            a.set position: [x, y]
        window.addEventListener 'mousemove', fmove
        window.addEventListener 'mouseup', () =>
          window.removeEventListener 'mousemove', fmove

applySelectAnimation = (symbol, rev=false) ->
    if symbol.selectionAnimation?
    then symbol.selectionAnimation.reverse()
    else
        anim = Animation.create
            easing      : Easing.quadInOut
            duration    : 0.1
            onUpdate    : (v) -> symbol.variables.selected = v
            onCompleted :     -> delete symbol.selectionAnimation
        if rev then anim.inverse()
        anim.start()
        symbol.selectionAnimation = anim
        anim

selectedComponent = null
makeSelectable = (a) ->
    a.addEventListener 'mousedown', (e) ->
        if e.button != 0 then return
        symbol = e.symbol
        if selectedComponent == symbol then return
        applySelectAnimation symbol
        if selectedComponent
            applySelectAnimation selectedComponent, true
            selectedComponent.variables.zIndex = 1
        selectedComponent = symbol
        selectedComponent.variables.zIndex = -10

expandedNodeShape = basegl.symbol shape.expandedNodeShape
expandedNodeShape.variables.selected = 0
expandedNodeShape.variables.bodyWidth = 200
expandedNodeShape.variables.bodyHeight = 300

expandedNodeErrorShape = basegl.symbol shape.expandedNodeErrorShape
expandedNodeErrorShape.variables.selected = 0
expandedNodeErrorShape.variables.bodyWidth = 200
expandedNodeErrorShape.variables.bodyHeight = 300

compactNodeShape = basegl.symbol shape.compactNodeShape
compactNodeShape.variables.selected = 0
compactNodeShape.bbox.xy = [shape.width, shape.height]

compactNodeErrorShape = basegl.symbol shape.compactNodeErrorShape
compactNodeErrorShape.variables.selected = 0
compactNodeErrorShape.bbox.xy = [shape.errorWidth, shape.errorHeight]


export class ExpressionNode extends Component
    updateModel: ({ key:        @key        = @key
                  , name:        name       = @name
                  , expression:  expression = @expression
                  , error:       error      = @error
                  , inPorts:     inPorts    = @inPorts
                  , outPorts:    outPorts   = @outPorts
                  , position:   @position   = @position
                  , selected:   @selected   = @selected
                  , expanded:    expanded   = @expanded}) =>
        if @expanded != expanded or @name != name or @expression != expression or @error != error
            @name = name
            @expression = expression
            @error = error
            nameDef = util.text str: @name
            exprDef = util.text str: @expression
            nodeShape = if expanded then expandedNodeShape else compactNodeShape
            @def = [{ name: 'node', def: nodeShape }
                   ,{ name: 'name', def: nameDef }
                   ,{ name: 'expression', def: exprDef }
                   ]
            if @error?
                errorFrame = if expanded then expandedNodeErrorShape else compactNodeErrorShape
                errorText  = util.text str: @error
                @def.splice 0, 0, {name: 'errorFrame', def: errorFrame}, {name: 'errorText', def: errorText}
            @expanded = expanded
            if @view?
                @reattach()
        @widgets ?= {}
        @setInPorts inPorts
        @setOutPorts outPorts
        @updateInPorts()
        @updateOutPorts()

    setInPorts: (inPorts) =>
        @inPorts ?= {}
        if inPorts.length?
            for inPort in inPorts
                @setInPort inPort
        else
            for inPortKey in Object.keys inPorts
                @setInPort inPorts[inPortKey]

    setInPort: (inPort) =>
        if @inPorts[inPort.key]?
            @inPorts[inPort.key].set inPort
        else
            portView = new InPort inPort, @
            @inPorts[inPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    setOutPorts: (outPorts) =>
        @outPorts ?= {}
        if outPorts.length?
            for outPort in outPorts
                @setOutPort outPort
        else
            for outPortKey in Object.keys outPorts
                @setOutPort outPorts[outPortKey]

    setOutPort: (outPort) =>
        if @outPorts[outPort.key]?
            @outPorts[outPort.key].set outPort
        else
            portView = new OutPort outPort, @
            @outPorts[outPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    drawWidgets: (widgets, startPoint, width) =>
        return unless widgets.length > 0
        ws = []
        minWidth = 0
        for i in [0..widgets.length - 1]
            ws.push
                index  : i
                widget : widgets[i]
                width : widgets[i].minWidth
            minWidth += widgets[i].minWidth
            widgets[i].configure siblings:
                left:  ! (i == 0)
                right: ! (i == widgets.length - 1)
        offset = 3
        free = width - minWidth - offset * (widgets.length - 1)
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
        ws.forEach (w) ->
            widgets[w.index].set position: startPoint.slice()
            widgets[w.index].configure width: w.width
            startPoint[0] += w.width + offset

    updateView: =>
        if @expanded
            bodyWidth = 200
            bodyHeight = 300
            @view.node.variables.bodyHeight = bodyHeight
            @view.node.variables.bodyWidth  = bodyWidth
            @view.node.position.xy = [-shape.width/2, -bodyHeight - shape.height/2]
            if @error?
                @view.errorFrame.variables.bodyHeight = bodyHeight
                @view.errorFrame.variables.bodyWidth  = bodyWidth
                @view.errorFrame.position.xy = [-shape.width/2, -bodyHeight - shape.height/2]
                errorSize = util.textSize @view.errorText
                @view.errorText.position.y = -bodyHeight - shape.height/2 - errorSize[1]/2
            Object.keys(@inPorts).forEach (inPortKey) =>
                widgets = @widgets[inPortKey]
                if widgets?
                    inPort = @inPorts[inPortKey]
                    @drawWidgets widgets, inPort.position.slice(), bodyWidth
        else
            @view.node.position.xy = [-shape.width/2, -shape.height/2]
            if @error?
                @view.errorFrame.position.xy = [-shape.width/2, -shape.height/2]
                errorSize = util.textSize @view.errorText
                @view.errorText.position.xy = [- errorSize[0]/2, -shape.height/2 - errorSize[1]/2]
        nameSize = util.textSize @view.name
        exprWidth = util.textWidth @view.expression
        @view.name.position.xy = [-nameSize[0]/2, shape.width/2 + nameSize[1]*2]
        @view.expression.position.xy = [-exprWidth/2, shape.width/2]
        @group.position.xy = @position.slice()
        @view.node.variables.selected = if @selected then 1 else 0

    updateInPorts: =>
        inPortNumber = 0
        inPortKeys = Object.keys @inPorts
        for inPortKey in inPortKeys
            inPort = @inPorts[inPortKey]
            values = {}
            unless inPort.angle?
                if @expanded or inPortKeys.length == 1
                    values.angle = Math.PI/2
                else
                    values.angle = Math.PI * (0.25 + 0.5 * inPortNumber/(inPortKeys.length-1))
            values.locked = @expanded
            if @expanded
                values.position = [@position[0] - shape.height/2, @position[1] - shape.height/2 - inPortNumber * 50]
                values.radius = 0
                unless @widgets[inPortKey]?
                    @widgets[inPortKey] = []
                    inPort.widgets.forEach (widgetCreate) =>
                        widget = widgetCreate @parent
                        widget.attach()
                        @onDispose => widget.dispose()
                        @widgets[inPortKey].push widget
            else
                if @widgets[inPortKey]?
                    @widgets[inPortKey].forEach (widget) =>
                        widget.detach()
                    delete @widgets[inPortKey]
                values.position = @position.slice()
                values.radius = shape.height/2
            inPort.set values
            inPortNumber++

    updateOutPorts: =>
        outPortNumber = 0
        outPortKeys = Object.keys @outPorts
        for outPortKey in outPortKeys
            outPort = @outPorts[outPortKey]
            values = {}
            unless outPort.angle?
                if outPortKeys.length == 1
                    values.angle = Math.PI*3/2
                else
                    values.angle = Math.PI * (1.25 + 0.5 * outPortNumber/(outPortKeys.length-1))
                values.radius = shape.height/2
            values.position = @position.slice()
            outPort.set values
            outPortNumber++

    registerEvents: =>
        makeDraggable @, => @updateView()
        makeSelectable @view.node
        @group.addEventListener 'click', (e) => @pushEvent ['node-editor', 'node'], e
