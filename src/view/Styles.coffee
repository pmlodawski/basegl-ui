import {ContainerComponent} from 'abstract/ContainerComponent'
import {HorizontalLayout}   from 'widget/HorizontalLayout'
import {VerticalLayout}     from 'widget/VerticalLayout'
import {TextContainer}      from 'view/Text'
import {ContinousSlider}    from 'widget/Slider'



dependencyCache = {} # constructor.name -> (style, Set prop)

class StyleProvider
    constructor: (@styles, @component) ->
        dependencyCache[@component.constructor.name] ?=
            components: new Set
            props: new Set
            styles: @styles
        cached = dependencyCache[@component.constructor.name]
        cached.props.forEach (prop) =>
            @__addHandler @component, cached.styles, prop
        cached.components.add @component
        @component.onDispose => cached.components.delete @component

    get: (styles, prop) =>
        return if prop == '__isMixin__'
        if prop == 'revision'
            return styles[prop]
        cached = dependencyCache[@component.constructor.name]
        unless cached.props.has prop
            cached.props.add prop
            cached.components.forEach (component) =>
                @__addHandler component, styles, prop
        styles.model[prop]

    __addHandler: (component, styles, prop) =>
        setTimeout component.addDisposableListener styles, prop, =>
            component.forceReset()

presets =
    [
        baseColor_r: 1
        baseColor_g: 1
        baseColor_b: 1
        bgColor_h: 40
        bgColor_s: 0.08
        bgColor_l: 0.09
        node_selection_h: 50
        node_selection_s: 1
        node_selection_l: 0.6
        node_selection_a: 0.8
        connection_lineWidth: 2
        node_widgetOffset: 20
        node_widgetHeight: 20
        colorActiveGreen_r: 0
        colorActiveGreen_g: 1
        colorActiveGreen_b: 0
        colorActiveGreen_a: 0.8
        hoverAspect: 0.9
        sliderFront: 0.2
        sliderBg: 0.1
    ,
        baseColor_r: 0.5
        baseColor_g: 0.5
        baseColor_b: 0.5
        bgColor_h: 40
        bgColor_s: 0.08
        bgColor_l: 0.09
        node_selection_h: 50
        node_selection_s: 0.5
        node_selection_l: 0.6
        node_selection_a: 0.8
        connection_lineWidth: 2
        node_widgetOffset: 20
        node_widgetHeight: 20
        colorActiveGreen_r: 0
        colorActiveGreen_g: 0
        colorActiveGreen_b: 1
        colorActiveGreen_a: 0.8
        hoverAspect: 0.9
        sliderFront: 0.2
        sliderBg: 0.1
    ]

currentPreset = 0

export class Styles extends ContainerComponent
    initModel: =>
        Object.assign {}, presets[currentPreset]

    prepare: =>
        @revision = 0

    enable: =>
        @addDef 'dump', TextContainer,
            text: 'DUMP'
            frameColor: [0.3, 0.3, 0.3]
        @view('dump').position.y = 20
        @view('dump').addEventListener 'click', => @__dumpSettings()

        @addDef 'switch', TextContainer,
            text: 'SWITCH'
            frameColor: [0.3, 0.3, 0.3]
        @view('switch').position.xy = [50, 20]
        @view('switch').addEventListener 'click', => @__switchModel()

        @addDef 'vertical', VerticalLayout,
            width: 300

        children = for own key, val of @model
            minVal =
                if val < -1
                    -100
                else if val < 0
                    -1
                else
                    0
            maxVal =
                if val > 1
                    100
                else
                    1 
            cons: HorizontalLayout
            height: 10
            children:
                [
                    cons: TextContainer
                    text: key
                ,
                    cons: ContinousSlider
                    value: val
                    min: minVal
                    max: maxVal
                ]
        @updateDef 'vertical', children: children

        @def('vertical').model.children.forEach (c, key) =>
            child = @def('vertical').def(key)
            child.def(1).addEventListener 'value', (e) =>
                name = child.def(0).model.text
                x = {}
                x[name] = e.detail
                @revision++
                @set x

        dragHandler = (e) =>
            if e.button != 0 then return
            moveNodes = (e) =>
                @withScene (scene) =>
                    x = @__view.position.x + e.movementX * scene.camera.zoomFactor
                    y = @__view.position.y - e.movementY * scene.camera.zoomFactor
                    @__view.position.xy = [x, y]

            dragFinish = =>
                @pushEvent
                    tag: 'NodeMoveEvent'
                    position: @model.position
                window.removeEventListener 'mouseup', dragFinish
                window.removeEventListener 'mousemove', moveNodes
            window.addEventListener 'mouseup', dragFinish
            window.addEventListener 'mousemove', moveNodes
        @view('vertical').addEventListener 'mousedown', dragHandler

        @__view.position.xy = [700, 300]

    install: (component) =>
        sp = new StyleProvider @, component
        component.style = new Proxy @, sp

    __dumpSettings: =>
        str = ''
        for own k, v of @model
             str += k + ': ' + v.toString() + '\n'
        console.log str

    __switchModel: =>
        if currentPreset == 0
            currentPreset = 1
        else
            currentPreset = 0
        @revision++
        console.log 'switching', currentPreset, @revision, presets[currentPreset]
        @set presets[currentPreset]
