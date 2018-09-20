import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'


export animateVariable = (style, symbol, name, value) ->
    animate style, symbol, 'variables', name, value

export animatePosition = (style, target, name, value) ->
    animate style, target, 'position', name, value

export animate = (style, target, name1, name2, rev) ->
    animationName = "#{name1}#{name2}Animation"
    target[animationName].cancel() if target[animationName]?
    oldVal = Number target[name1][name2]
    newVal = Number rev
    anim = Animation.create
        easing      : Easing.quadInOut
        duration    : style.transform_time
        onUpdate    : (v) ->
            result = oldVal + v * (newVal - oldVal)
            target[name1][name2] = result
        onCompleted :     -> delete target[animationName]
    target[animationName] = anim
    anim.start()
    anim
