import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {circle, pie, rect}  from 'basegl/display/Shape'

white          = Color.rgb [1,1,1]
bg             = (Color.hsl [40,0.08,0.09]).toRGB()
bgColor       = bg.mix white, 0.1
sliderColor    = bg.mix white, 0.2

export sliderShape = basegl.expr ->
    topLeft     = 'bbox.y'/2 * 'topLeft'
    topRight    = 'bbox.y'/2 * 'topRight'
    bottomLeft  = 'bbox.y'/2 * 'bottomLeft'
    bottomRight = 'bbox.y'/2 * 'bottomRight'
    valueWidth  = 'bbox.x' * 'level'
    background = rect 'bbox.x', 'bbox.y', topLeft, topRight, bottomLeft, bottomRight
    background = background.move 'bbox.x'/2, 'bbox.y'/2
    background = background.fill bgColor
    slider = rect valueWidth, 'bbox.y', topLeft, 0, bottomLeft, 0
    slider = slider.move valueWidth/2, 'bbox.y'/2
    slider = slider.fill sliderColor
    background + slider
