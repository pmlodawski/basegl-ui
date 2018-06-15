import {HasModel}  from "view/HasModel"
import * as _      from 'underscore'
import * as basegl from 'basegl/display/Symbol'


export class BasicComponent extends HasModel
    cons: (values, @parent) =>
        super values
        @prepare()
        @set values

    withScene: (fun) => @parent.withScene fun if @parent?

    __draw: (def) => @withScene (scene) =>
        @__element = scene.add def
        @__view = basegl.group [@__element]

    __undraw: (def) =>
        if def?
            @withScene (scene) =>
                scene.delete def
            @__element = null

    redefineRequred: => false

    onModelUpdate: =>
        if @redefineRequred(@changed) or (not @__def?)
            def = @define()
            if def? and not _.isEqual(def, @__def)
                @__undraw @__def
                @__draw def
                @registerEvents @__element
                @__def = def
        @adjust @__element, @__view

    destruct: =>
        @__undraw @__def

    # # implement this when deriving: #
    # #################################
    #
    # redefineRequred (values) =>
    #     # test values if it is required to redefine shape
    #
    # connectEvents (element) =>
    #     ....
    #     element.onEvent ...
    #     ...
    #
    # redefine =>
    #     # use @values to create def and return it
    #     ...
    #     return def
    #
    # adjust (element) =>
    #     # use @values to adjust element
    #     ...
    #     element.rotation = @values.angle
    #     ...
