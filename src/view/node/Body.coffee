import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {Expression}          from 'view/node/Expression'
import {Parameters}          from 'view/node/Parameters'
import {Searcher}            from 'view/node/Searcher'
import {FramedText}          from 'widget/FramedText'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'


export class NodeBody extends ContainerComponent
    initModel: =>
        expression: null
        expanded: false
        inPorts: {}
        controls: {}
        searcher: null
        newPortKey: null
        visualizers : null
        visualizations: {}
        value: null

    prepare: =>
        @addDef 'valueToggler', ValueTogglerShape
        @addDef 'body', VerticalLayout,
            width: @style.node_bodyWidth

    update: =>
        if @changed.value
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        body = []
        modules = []
        if @model.expanded or @model.searcher?
            modules.push
                id: 'expression'
                cons: Expression
                expression: @model.expression
                editing: @model.searcher?
            modules.push
                id: 'parameters'
                cons: Parameters
                inPorts: @model.inPorts
                controls: @model.controls
                newPortKey: @model.newPortKey
        for own k, visualization of @model.visualizations
            visualization.cons = Visualization
            visualization.visualizers = @model.visualizers
            modules.push visualization
        body.push
            id: 'modules'
            cons: VerticalLayout
            children: modules
        if @__shortValue()?
            body.push
                id: 'value'
                cons: FramedText
                textAlign: 'center'
                valign: 'top'
                color: [@style.text_color_r, @style.text_color_g, @style.text_color_b]
                text: @__shortValue()
        @updateDef 'body', children: body
        @autoUpdateDef 'searcher', Searcher, @model.searcher


    adjust: =>
        @view('searcher')?.position.x = @style.node_bodyWidth + 3
        @view('valueToggler').position.xy =
            [ @style.visualization_togglerX, @style.visualization_togglerY ]
    
    registerEvents: =>
        @view('valueToggler').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'ToggleVisualizationsEvent'

    __shortValue: =>
        @model.value?.contents?.contents

    portPosition: (key) =>
        @__defs.body.positions['modules'][1] \
        + @__defs.body.__defs.modules.positions['parameters'][1] \
        + @__defs.body.__defs.modules.__defs.parameters.__defs.widgets.positions[key][1]
