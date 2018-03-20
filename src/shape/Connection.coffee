import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie, rect}  from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/Node'

export width     = 20

lineWidth = 2

export connectionShape = basegl.expr ->
    eye         = 'scaledEye.z'
    scaledWidth = lineWidth * Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.7) / 10
    r = rect 'bbox.x', scaledWidth
    r.move 'bbox.x'/2, 'bbox.y'/2

