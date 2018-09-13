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

blacklist = new Set ['enabled', 'presetNo']
presets =
    [
        baseColor_r: 1
        baseColor_g: 1
        baseColor_b: 1
        bgColor_h: 0
        bgColor_s: 0.00001
        bgColor_l: 0.93
        node_radius: 18.75
        node_headerOffset: 20
        node_slope: 20
        node_bodyWidth: 200
        node_selection_size: 20
        node_selection_h: 50
        node_selection_s: 1
        node_selection_l: 0.6
        node_selection_a: 0.8
        node_selectionBorderMaxSize: 40
        node_shadowRadius: 24.58
        node_shadowPower: 2
        node_shadowOpacity: 0.03
        node_opacity: 1
        node_widgetOffset_h: 16.58
        node_widgetOffset_v: 6.65
        node_widgetHeight: 20
        node_widgetSeparation: 3
        port_length: 10
        port_angle: 1.0471975511965976
        port_distance: 16.47
        connection_lineWidth: 2
        colorActiveGreen_r: 0
        colorActiveGreen_g: 1
        colorActiveGreen_b: 0
        colorActiveGreen_a: 0.8
        hoverAspect: 0.9
        sliderFront: 0.2
        sliderBg: 0.1
        textColor_r: 0.1
        textColor_g: 0.1
        textColor_b: 0.1
    ,
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
        node_shadowRadius: 50
        node_shadowPower: 1
        node_shadowOpacity: 0.3
        node_opacity: 0.04
        connection_lineWidth: 2
        node_widgetOffset_h: 20
        node_widgetOffset_v: 20
        node_widgetHeight: 20
        colorActiveGreen_r: 0
        colorActiveGreen_g: 1
        colorActiveGreen_b: 0
        colorActiveGreen_a: 0.8
        hoverAspect: 0.9
        sliderFront: 0.2
        sliderBg: 0.1
        textColor_r: 1
        textColor_g: 1
        textColor_b: 1
    ]


export class Styles extends ContainerComponent
    initModel: =>
        model =
            enabled: false
            presetNo: 0
        Object.assign model, presets[model.presetNo]

    prepare: =>
        @revision = 0

    update: =>
        if @changed.enabled or @changed.presetNo
            @autoUpdateDef 'dump', TextContainer, if @model.enabled
                text: 'DUMP'
                frameColor: [0.3, 0.3, 0.3]
            @autoUpdateDef 'switch', TextContainer, if @model.enabled
                text: 'SWITCH'
                frameColor: [0.3, 0.3, 0.3]
            @autoUpdateDef 'vertical', VerticalLayout, if @model.enabled
                width: 300
                children: for own key, val of @model
                    continue if blacklist.has key
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
        if (@changed.enabled or @changed.presetNo) and @model.enabled
            @def('vertical').model.children.forEach (c, key) =>
                child = @def('vertical').def(key)
                child.def(1).addEventListener 'value', (e) =>
                    name = child.def(0).model.text
                    x = {}
                    x[name] = e.detail
                    @revision++
                    @set x

        # if @changed.bgColor_h or @changed.bgColor_s or @changed.bgColor_l or @changed.presetNo
        document.getElementById('basegl-root').style.background="hsl("+@model.bgColor_h+","+@model.bgColor_s*100+"%,"+@model.bgColor_l*100+"%)"


    adjust: (view) =>
        if (@changed.enabled or @changed.presetNo) and @model.enabled
            @view('dump').position.y = 20
            @view('dump').addEventListener 'click', => @__dumpSettings()

            @view('switch').position.xy = [50, 20]
            @view('switch').addEventListener 'click', => @__switchModel()
        if @changed.once
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
            view.addEventListener 'mousedown', dragHandler
            view.position.xy = [700, 500]

    install: (component) =>
        sp = new StyleProvider @, component
        component.style = new Proxy @, sp

    __dumpSettings: =>
        str = ''
        for own k, v of @model
             str += k + ': ' + v.toString() + '\n'
        console.log str

    __switchModel: =>
        @revision++
        Object.assign presets[@model.presetNo], @model
        newPresetNo = if @model.presetNo then 0 else 1
        newModel = Object.assign {presetNo: newPresetNo}, presets[newPresetNo]
        @set newModel
