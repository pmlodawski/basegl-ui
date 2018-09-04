import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'
export width     = 30


export connectionExpr = (styles) -> basegl.expr ->
    eye         = 'scaledEye.z'
    scaledWidth = styles.connection_lineWidth * Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.85) / 10
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    connection = rect 'bbox.x', scaledWidth
       .move 'bbox.x'/2, 'bbox.y'/2
       .fill color.varHover()
    activeArea + connection

connectionSymbol = memoizedSymbol (styles) ->
    symbol = basegl.symbol connectionExpr(styles)
    symbol.defaultZIndex = layers.connection
    symbol.bbox.y = width
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol


export class ConnectionShape extends BasicComponent
    initModel: =>
        offset: 0
        length: 0
        angle: 0
        color: [1,0,0]

    define: =>
        connectionSymbol @styles

    adjust: (element, view) =>
        if @changed.length
            element.bbox.x = @model.length
        if @changed.offset
            element.position.x = @model.offset
        element.position.y = - width/2
        if @changed.angle
            element.rotation.z = @model.angle
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        vars = @getElement().variables
        view.addEventListener 'mouseover', => vars.hovered = 1
        view.addEventListener 'mouseout',  => vars.hovered = 0
        @watchStyles 'connection_lineWidth'
