import * as Color     from 'basegl/display/Color'
import * as basegl    from 'basegl'

export white          = Color.rgb [1,1,1]
export base           = (styles) -> basegl.expr ->
    Color.rgb [styles.baseColor_r, styles.baseColor_g, styles.baseColor_b]
export bg             = (styles) -> basegl.expr ->
    (Color.hsl [styles.bgColor_h, styles.bgColor_s, styles.bgColor_l]).toRGB()
export selectionColor = (styles) -> basegl.expr ->
    bg(styles).mix (Color.hsl [styles.node_selection_h, styles.node_selection_s, styles.node_selection_l]), styles.node_selection_a
export nodeBg         = (styles) -> basegl.expr ->
    bg(styles).mix base(styles), 0.04

export valueTogglerColor = white
export visualizationMenu = valueTogglerColor

export transparent = Color.rgb [0, 0, 0, 0]
export activeArea = transparent
export hoverAspect = 0.9

export varHover = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b']
        .mix white, 'hovered' * hoverAspect

export varAlpha = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']

export varAlphaHover = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']
        .mix white, 'hovered' * hoverAspect

export sliderColor   = (styles) -> basegl.expr ->
    bg(styles).mix base(styles), 0.2
export sliderBgColor = (styles) -> basegl.expr ->
    bg(styles).mix base(styles), 0.1
export activeGreen = Color.rgb [0, 1, 0, 0.8]
