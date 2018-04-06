import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie}  from 'basegl/display/Shape'
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
       .fill Color.rgb ['color_r', 'color_g', 'color_b']
    port = c * p

export outPortShape = basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move width/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move width/2, h2 + r
       .fill Color.rgb ['color_r', 'color_g', 'color_b']
    port = p - c
    port.move 0, -r+length-h2

export flatPortShape = basegl.expr ->
    r = outArrowRadius
    p = pie -angle
    p = p.rotate -Math.PI /2
    p = p.move length + 1, width/2
    p = p.fill Color.rgb ['color_r', 'color_g', 'color_b']
