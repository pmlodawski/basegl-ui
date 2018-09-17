import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Easing      from 'basegl/animation/Easing'
import * as Color       from 'basegl/display/Color'
import {rect, plane}    from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as style       from 'style'
import * as layers      from 'view/layers'
import * as color       from 'shape/Color'


visualizationCoverShape = (style) -> basegl.expr ->
    shape = plane()
    shape = shape.fill color.activeArea
    shape = shape.move style.visualization_height/2, style.visualization_width/2

visualizationCoverSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol visualizationCoverShape style
    symbol.defaultZIndex = layers.visualizationCover
    symbol.bbox.xy       = [style.visualization_width, style.visualization_height]
    symbol

export class VisualizationCoverShape extends BasicComponent
    define: => visualizationCoverSymbol @style
    adjust: (element) =>
        if @changed.once
            element.position.y = -@style.visualization_height
