import {BackgroundShape}      from 'shape/node/Background'
import {Widget}           from 'widget/Widget'
import {VerticalLayout}   from 'widget/VerticalLayout'
import {HorizontalLayout} from 'widget/HorizontalLayout'

export class Parameters extends Widget
    initModel: =>
        model = super()
        model.inPorts = {}
        model

    update: =>
        if @changed.inPorts
            @autoUpdateDef 'widgets', VerticalLayout,
                width: @style.node_bodyWidth - 2*@style.node_widgetOffset_h
                offset: @style.node_widgetOffset_v
                children: for own key, inPort of @model.inPorts
                    key: key
                    cons: HorizontalLayout
                    children: inPort.controls
                    offset: @style.node_widgetSeparation
            @__minHeight = @def('widgets').height() + @style.node_widgetOffset_v

            @autoUpdateDef 'background', BackgroundShape,
                height: @__minHeight
                width: @style.node_bodyWidth
        if @changed.siblings
            @updateDef 'background',
                roundBottom: not @model.siblings.bottom
                roundTop:    not @model.siblings.top
    adjustSrc: (view) =>
        view.position.xy = [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @view('widgets').scale.xy = [0,0]
        @view('background').scale.xy = [0,0]
        # @animatePosition view, [@style.node_widgetOffset_h, 0]
        # @animatePosition view, [0, 100]
    adjustDst: (view) =>
        @animatePosition view, [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @animateScale @view('widgets'), [0,0]
        @animateScale @view('background'), [0, 0]

    adjust: (view) =>
        if @changed.once
            @animatePosition view, [0, 0]
            @animateScale @view('widgets'), [1, 1]
            @animateScale @view('background'), [1, 1]
            @view('widgets').position.xy = [@style.node_widgetOffset_h, - @style.node_widgetHeight/2]
