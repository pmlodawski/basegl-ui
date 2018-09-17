import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'


export applyAnimation = (style, symbol, name, rev=false) ->
    animationName = "{name}Animation"
    if symbol[animationName]?
    then symbol[animationName].reverse()
    else
        anim = Animation.create
            easing      : Easing.quadInOut
            duration    : style.transform_time
            onUpdate    : (v) -> symbol.variables[name] = v
            onCompleted :     -> delete symbol[animationName]
        if rev then anim.inverse()
        anim.start()
        symbol[animationName] = anim
        anim