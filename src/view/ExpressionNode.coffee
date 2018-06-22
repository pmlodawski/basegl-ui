import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {group}        from 'basegl/display/Symbol'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort}             from 'view/port/In'
import {OutPort}            from 'view/port/Out'
import * as shape           from 'shape/node/Base'
import * as util            from 'shape/util'
import * as _               from 'underscore'
import {BasicComponent}     from 'abstract/BasicComponent'
import {Component}          from 'abstract/Component'
import {ContainerComponent} from 'abstract/ContainerComponent'
import {TextShape}          from 'shape/Text'
import {NodeShape}          from 'shape/node/Node'
import {NodeErrorShape}     from 'shape/node/ErrorFrame'
import {ValueTogglerShape}  from 'shape/node/ValueToggler'

### Utils ###
selectedNode = null



nodeExprYOffset = shape.height / 3
nodeNameYOffset = nodeExprYOffset + 15
nodeValYOffset  = -nodeNameYOffset

portDistance = shape.height / 3


export class ExpressionNode extends ContainerComponent
    initModel: =>
        key:        null
        name:       ''
        expression: ''
        value:      null
        inPorts:    {}
        outPorts:   {}
        position:   [0, 0]
        selected:   false
        expanded:   false
        hovered:    false

    prepare: =>
        @addDef 'node', new NodeShape expanded: @model.expanded, @
        @addDef 'name', new TextShape text: @model.name, @
        @addDef 'expression', new TextShape text: @model.expression, @
        @addDef 'valueToggler', new ValueTogglerShape null, @

    update: =>
        @updateDef 'name', text: @model.name
        @updateDef 'expression', text: @model.expression

        setInPort  = (k, inPort)  => @autoUpdateDef ('in'  + k),  InPort,  inPort
        for own k, inPort of @model.inPorts
            setInPort k, inPort
        setOutPort = (k, outPort) => @autoUpdateDef ('out' + k), OutPort, outPort
        for own k, outPort of @model.outPorts
            setOutPort k, outPort
        @updateInPorts()
        @updateOutPorts()

        @updateDef 'node',
            expanded: @model.expanded
            selected: @model.selected
            body: [@bodyWidth, @bodyHeight]

        if @changed.value
            @autoUpdateDef 'errorFrame', NodeErrorShape, if @error()
                expanded: @model.expanded
                body: [@bodyWidth, @bodyHeight]
            @autoUpdateDef 'value', TextShape, if @shortValue()?
                text: @shortValue()
                body: [@bodyWidth, @bodyHeight]

        @updateDef 'valueToggler',
            isFolded: @model.value?.contents?.tag != 'Visualization'
            expanded: @model.expanded
            body: [@bodyWidth, @bodyHeight]


        # @widgets ?= {}

    outPort: (key) => @def ('out' + key)
    inPort: (key) => @def ('in' + key)

    error: =>
        @model.value? and @model.value.tag == 'Error'

    shortValue: =>
        if @model.value? and @model.value.contents?
            @model.value.contents.contents

    # drawWidgets: (widgets, startPoint, width) =>
    #     return unless widgets.length > 0
    #     ws = []
    #     minWidth = 0
    #     for i in [0..widgets.length - 1]
    #         ws.push
    #             index  : i
    #             widget : widgets[i]
    #             width : widgets[i].minWidth
    #         minWidth += widgets[i].minWidth
    #         widgets[i].configure siblings:
    #             left:  ! (i == 0)
    #             right: ! (i == widgets.length - 1)
    #     offset = 3
    #     free = width - minWidth - offset * (widgets.length - 1)
    #     ws.sort (a, b) -> a.widget.maxWidth - b.widget.maxWidth
    #     for i in [0..ws.length - 1]
    #         w = ws[i]
    #         wfree = free / (ws.length - i)
    #         if (! w.widget.maxWidth?) or w.widget.maxWidth > w.width + wfree
    #             free -= wfree
    #             w.width += wfree
    #         else
    #             free -= w.widget.maxWidth - w.width
    #             w.width = w.widget.maxWidth
    #     ws.forEach (w) ->
    #         widgets[w.index].set position: startPoint.slice()
    #         widgets[w.index].configure width: w.width
    #         startPoint[0] += w.width + offset

    # updateValueView: =>
    #     valueSize     = [0,0]
    #     valuePosition = @view('node').position
    #     if @shortValue()?
    #         @view('value').position.y = @view('node').position.y
    #         valuePosition = @view('value').position
    #     @view('valueToggler').position.y = @view('node').position.y
        
    adjust: (view) =>
        # if @model.expanded
        #     for own inPortKey, inPort of @inPorts
        #         widgets = @widgets[inPortKey]
        #         if widgets?
        #             leftOffset = 50
        #             startPoint = [inPort.position[0] + leftOffset, inPort.position[1]]
        #             width = @bodyWidth - 20
        #             @drawWidgets widgets, startPoint, width
        # @updateValueView()
        @view('name').position.y = nodeNameYOffset
        @view('expression').position.y = nodeExprYOffset
        view.position.xy = @model.position.slice()

    updateInPorts: =>
        inPortNumber = 0
        inPortKeys = Object.keys @model.inPorts
        for inPortKey, inPort of @model.inPorts
            values = {}
            values.locked = @model.expanded
            if inPort.mode == 'self'
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [0, 0]
            else if @model.expanded
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [- shape.height/2
                                  ,- shape.height/2 - inPortNumber * 50]
                inPortNumber++
            else
                values.position = [0,0]
                values.radius = portDistance
                if inPortKeys.length == 1
                    values.angle = Math.PI/2
                else
                    values.angle = Math.PI * (0.25 + 0.5 * inPortNumber/(inPortKeys.length-1))
                inPortNumber++
            @def('in' + inPortKey).set values

            # if @model.expanded
            #     unless @widgets[inPortKey]?
            #         @widgets[inPortKey] = []
            #         inPort.widgets.forEach (widgetCreate) =>
            #             widget = widgetCreate @parent
            #             @onDispose => widget.dispose()
            #             @widgets[inPortKey].push widget
            # else
            #     if @widgets[inPortKey]?
            #         @widgets[inPortKey].forEach (widget) =>
            #             widget.detach()
            #         delete @widgets[inPortKey]
            # inPort.set values
        # Those values should be calculated based on informations about port widgets
        @bodyWidth = 200
        @bodyHeight = 300

    updateOutPorts: =>
        outPortNumber = 0
        outPortKeys = Object.keys @model.outPorts
        for own outPortKey, outPort of @model.outPorts
            values = {}
            unless outPort.angle?
                if outPortKeys.length == 1
                    values.angle = Math.PI*3/2
                else
                    values.angle = Math.PI * (1.25 + 0.5 * outPortNumber/(outPortKeys.length-1))
                values.radius = portDistance
            @def('out' + outPortKey).set values
            outPortNumber++

    registerEvents: (view) =>
        view.addEventListener 'dblclick',  @pushEvent
        @view('valueToggler').addEventListener 'mouseup', => @pushEvent
            tag: 'ToggleVisualizationsEvent'
        @makeHoverable view
        @makeDraggable view
        @makeSelectable view

    makeHoverable: (view) =>
        view.addEventListener 'mouseenter', => @set hovered: true
        view.addEventListener 'mouseleave', => @set hovered: false

    makeSelectable: (view) =>
        @withScene (scene) =>
            performSelect = (select) =>
                target = selectedNode or @
                target.pushEvent
                    tag: 'NodeSelectEvent'
                    select: select
                target.set selected: select
                selectedNode = if select then @ else null

            unselect = (e) =>
                scene.removeEventListener 'mousedown', unselect
                performSelect false

            view.addEventListener 'mousedown', (e) =>
                if e.button != 0 then return
                if selectedNode == @
                    return
                else if selectedNode?
                    performSelect false
                performSelect true
                scene.addEventListener 'mousedown', unselect

    makeDraggable: (view) =>
        dragHandler = (e) =>
            if e.button != 0 then return
            moveNodes = (e) =>
                @withScene (scene) =>
                    x = @model.position[0] + e.movementX * scene.camera.zoomFactor
                    y = @model.position[1] - e.movementY * scene.camera.zoomFactor
                    @set position: [x, y]

            dragFinish = =>
                @pushEvent
                    tag: 'NodeMoveEvent'
                    position: @position
                window.removeEventListener 'mouseup', dragFinish
                window.removeEventListener 'mousemove', moveNodes
            window.addEventListener 'mouseup', dragFinish
            window.addEventListener 'mousemove', moveNodes
        view.addEventListener 'mousedown', dragHandler
