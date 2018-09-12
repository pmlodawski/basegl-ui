import * as basegl    from 'basegl'
import {circle, glslShape, rect} from 'basegl/display/Shape'

#### basic shapes ####


export width = (style) -> style.node_radius * 2 + style.node_selectionBorderMaxSize * 2
export height = (style) -> style.node_radius * 2 + style.node_selectionBorderMaxSize * 2
export slope = 20

export compactNodeExpr = (style) -> basegl.expr ->
    r1     = style.node_radius
    node   = circle r1
    node   = node.move width(style)/2, height(style)/2

export expandedNodeExpr = (style) -> basegl.expr ->
    bodyWidth    = 'bodyWidth'
    bodyHeight   = 'bodyHeight'
    r1    = style.node_radius
    r2    = style.node_radius + style.node_headerOffset + slope
    dy    = slope
    dx    = Math.sqrt ((r1+r2)*(r1+r2) - dy*dy)
    angle = Math.atan(dy/dx)

    maskPlane   = glslShape("-sdf_halfplane(p, vec2(1.0,0.0));").moveX(dx)
    maskRect    = rect(r1+r2, r2 * Math.cos(-angle)).alignedTL.rotate(-angle)
    mask        = (maskRect - maskPlane).inside
    headerShape = (circle(r1) + mask) - circle(r2).move(dx,dy)
    headerFill  = rect(r1*2, style.node_radius + style.node_headerOffset + 10)
        .alignedTL.moveX(-r1)
    header = (headerShape + headerFill)
        .move(style.node_radius,style.node_radius)
        .moveY(style.node_headerOffset + bodyHeight)
    body = rect(bodyWidth, bodyHeight, 0, style.node_radius).alignedBL
    node = (header + body)
        .move(style.node_selectionBorderMaxSize, style.node_selectionBorderMaxSize)
