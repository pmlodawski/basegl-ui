import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {rect, plane}  from 'basegl/display/Shape'

# white       = Color.rgb [1,1,1]
transparent = Color.rgb [0,0,0,0]

export width  = 300
export height = 300

export visualizationCover = basegl.expr ->
    shape = plane()
    shape = shape.fill transparent
    shape = shape.move height/2, width/2
