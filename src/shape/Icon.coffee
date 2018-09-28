import * as basegl         from 'basegl'
import * as Color          from 'basegl/display/Color'
import {circle, rect}            from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {length, PortShape} from 'shape/port/Base'
import * as layers         from 'view/layers'


### UTILS ###

radius = (style) -> style.port_selfRadius

createSymbol = (expr) -> memoizedSymbol (style) ->
    symbol = basegl.symbol expr style
    symbol.bbox.xy = [2 * radius(style), 2 * radius(style)]
    symbol.defaultZIndex = layers.icon
    symbol

export class IconShape extends BasicComponent
    initModel: =>
        shape: null
    redefineRequired: => @changed.shape
    define: => @model.shape @style
    adjust: (element) =>
        element.position.xy = [-radius(@style), -radius(@style)]

### CUSTOM SYMBOLS ###

export stripesIcon = createSymbol (style) -> basegl.expr ->
    c = circle 'bbox.x'/2
       .move 'bbox.x'/2, 'bbox.y'/2
       .fill Color.rgb [43/256, 101/256, 251/256]
    stripe2 = rect 'bbox.x'*0.46, 'bbox.y'*0.125, 1
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill Color.rgb [1, 1, 1]
    stripe1 = stripe2.move 0, 'bbox.y'*0.165
    stripe3 = stripe2.move 0, 'bbox.y'*(-0.165)
        .fill Color.rgb [172/256, 195/256, 253/256]
    c + stripe1 + stripe2 + stripe3

export rectIcon = createSymbol (style) -> basegl.expr ->
    c = circle 'bbox.x'/2
       .move 'bbox.x'/2, 'bbox.y'/2
       .fill Color.rgb [43/256, 101/256, 251/256]
    r = rect 'bbox.x'/2, 'bbox.y'/2
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill Color.rgb [172/256, 195/256, 253/256]
    c + r
