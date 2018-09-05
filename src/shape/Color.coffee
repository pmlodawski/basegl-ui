import * as Color     from 'basegl/display/Color'
import * as basegl    from 'basegl'

export white          = Color.rgb [1,1,1]
export base           = (style) -> basegl.expr ->
    Color.rgb [style.baseColor_r, style.baseColor_g, style.baseColor_b]
export bg             = (style) -> basegl.expr ->
    (Color.hsl [style.bgColor_h, style.bgColor_s, style.bgColor_l]).toRGB()
export selectionColor = (style) -> basegl.expr ->
    bg(style).mix (Color.hsl [style.node_selection_h, style.node_selection_s, style.node_selection_l]), style.node_selection_a
export nodeBg         = (style) -> basegl.expr ->
    bg(style).mix base(style), 0.04

export valueTogglerColor = white
export visualizationMenu = valueTogglerColor

export transparent = Color.rgb [0, 0, 0, 0]
export activeArea = transparent
export hoverAspect = 0.9

export varHover = (style) -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b']
        .mix base(style), 'hovered' * hoverAspect

export varAlpha = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']

export varAlphaHover = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']
        .mix white, 'hovered' * hoverAspect

export sliderColor   = (style) -> basegl.expr ->
    bg(style).mix base(style), 0.2
export sliderBgColor = (style) -> basegl.expr ->
    bg(style).mix base(style), 0.1
export activeGreen = Color.rgb [0, 1, 0, 0.8]
