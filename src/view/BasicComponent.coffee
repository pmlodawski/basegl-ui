import {HasModel}  from "view/HasModel"
import * as _      from 'underscore'
import * as basegl from 'basegl/display/Symbol'


export class BasicComponent extends HasModel
    __draw: (def) => @withScene (scene) =>
        @__element = scene.add def
        @__view = basegl.group [@__element]

    __undraw: (def) => @withScene (scene) =>
        if def?
            scene.delete def
            @__element = null

    redefineRequred: => false

    onModelUpdate: =>
        if @redefineRequred(@changed) or (not @__def?)
            def = @define()
            if def? and not _.isEqual(def, @__def)
                @__undraw @__def
                @__draw def
                @registerEvents? @__element
                @__def = def
        @adjust @__element, @__view

    destruct: =>
        @__undraw @__def

    # # implement following methods when deriving: #
    # ##############################################
    #
    # initModel: =>
    #     # return model structure (optional, default: {})
    #
    # prepare: =>
    #     # initialize component (optional)
    #
    # redefineRequred (values) =>
    #     # test values if it is required to redefine shape (optional, default: false)
    #
    # define =>
    #     # use @values to create def and return it
    #     ...
    #     return def
    #
    # registerEvents: (element) =>
    #     # register events on element being group of all defs (optional)
    #
    # adjust (element, view) =>
    #     # use @values to adjust element and view
    #     ...
    #     element.rotation = @values.angle
    #     ...
