import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie, rect}  from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/Node'

angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle
distanceFromCenter = nodeSelectionBorderMaxSize
inArrowRadius    = length + distanceFromCenter
outArrowRadius    = distanceFromCenter


export inPortShape = basegl.expr ->
    r = inArrowRadius
    c = circle r
       .move width/2, -distanceFromCenter
    p = pie angle
       .rotate Math.PI
       .move width/2, 0
    port = c * p
    port.fill Color.rgb ['color_r', 'color_g', 'color_b']

export outPortShape = basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move width/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move width/2, h2 + r
    port = p - c
    port.move 0, -r+length-h2
        .fill Color.rgb ['color_r', 'color_g', 'color_b']

export flatPortShape = basegl.expr ->
    r = outArrowRadius
    p = pie -angle
       .rotate -Math.PI /2
       .move length + 1, width/2
       .fill Color.rgb ['color_r', 'color_g', 'color_b']


selfPortRadius = length
export selfPortWidth = 2 * selfPortRadius
export selfPortHeight = 2 * selfPortRadius

export selfPortShape = basegl.expr ->
    c = circle selfPortRadius
       .move selfPortRadius, selfPortRadius
       .fill Color.rgb ['color_r', 'color_g', 'color_b']


addPortRadius = length
export addPortWidth = 2 * addPortRadius
export addPortHeight = 2 * addPortRadius
plusLength = addPortWidth / 2
plusThickness = plusLength/4

export addPortShape = basegl.expr ->
    c = circle addPortRadius
       .move addPortRadius, addPortRadius
    horizontal = rect plusLength, plusThickness
                .move addPortRadius, addPortRadius
    vertical = rect plusThickness, plusLength
              .move addPortRadius, addPortRadius
    plus = horizontal + vertical
    port = c - plus
    port.fill Color.rgb [0.2, 0.2, 0.2]
