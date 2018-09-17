import {ModuleShape}      from 'shape/node/Module'
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
                width: @style.node_bodyWidth - @style.node_widgetOffset_h
                offset: @style.node_widgetOffset_v
                children: for own key, inPort of @model.inPorts
                    key: key
                    cons: HorizontalLayout
                    children: inPort.controls
                    offset: @style.node_widgetSeparation
            @__minHeight = @def('widgets').height() + @style.node_widgetOffset_v

            @autoUpdateDef 'box', ModuleShape,
                height: @__minHeight
                width: @style.node_bodyWidth

    adjust: =>
        if @changed.once
            @view('widgets').position.xy = [@style.node_widgetOffset_h/2, - @style.node_widgetHeight/2]
        