import {InPortShape}    from 'shape/port/In'


export class NewPortShape extends InPortShape
    initModel: =>
        model = super()
        model.lockHover = false
        model

    adjust: (element) =>
        super element
        if @changed.lockHover
            element.variables.color_a = @__alphaOnUnhover()

    __alphaOnUnhover: => Number @model.lockHover

    registerEvents: (view) =>
        animateHover = (value) =>
            @animateVariable 'color_a', not value

        view.addEventListener 'mouseover', => animateHover 1
        view.addEventListener 'mouseout',  => animateHover @__alphaOnUnhover()
