import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'


export animateVariable = (style, symbol, name, rev=false) ->
    animate style, symbol, name, ((v) -> symbol.variables[name] = v), rev

export animateComponent = (style, component, name, rev=false) ->
    setter = (v) ->
        obj = {}
        obj[name] = v
        component.set obj
    animate style, component, name, setter, rev
    # animationName = "{name}Animation"
    # if symbol[animationName]?
    # then symbol[animationName].reverse()
    # else
    #     anim = Animation.create
    #         easing      : Easing.quadInOut
    #         duration    : style.transform_time
    #         onUpdate    : (v) -> symbol.variables[name] = v
    #         onCompleted :     -> delete symbol[animationName]
    #     if rev then anim.inverse()
    #     anim.start()
    #     symbol[animationName] = anim
    #     anim

export animate = (style, target, name, setter, rev=false) ->
    animationName = "#{name}Animation"
    if target[animationName]?
    then target[animationName].reverse()
    else
        anim = Animation.create
            easing      : Easing.quadInOut
            duration    : style.transform_time
            onUpdate    : (v) -> setter v
            onCompleted :     -> delete target[animationName]
        if rev then anim.inverse()
        anim.start()
        target[animationName] = anim
        anim