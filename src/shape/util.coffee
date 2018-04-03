import * as basegl    from 'basegl'


export textWidth = (textGroup) =>
    textMinX = undefined
    textMaxX = undefined
    textGroup.children.forEach (child) =>
        l = child.position.x
        r = child.position.x + child.bbox.x
        textMinX = l unless l > textMinX
        textMaxX = r unless r < textMaxX
    textMaxX - textMinX

export textSize = (textGroup) =>
    textMinX = undefined
    textMaxX = undefined
    textMinY = undefined
    textMaxY = undefined
    textGroup.children.forEach (child) =>
        l = child.position.x
        r = child.position.x + child.bbox.x
        textMinX = l unless l > textMinX
        textMaxX = r unless r < textMaxX
        b = child.position.y
        t = child.position.y + child.bbox.y
        textMinY = b unless b > textMinY
        textMaxY = t unless t < textMaxY
    [textMaxX - textMinX, textMaxY - textMinY]

export text = (attrs) =>
    addToScene: (scene) =>
        attrs.scene = scene
        basegl.text attrs