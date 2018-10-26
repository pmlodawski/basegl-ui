import {ContainerComponent} from 'abstract/ContainerComponent'


export class Subport extends ContainerComponent
    registerEvents: (view) =>
        view.addEventListener 'mouseup', (e) => @pushEvent e
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent e
        view.addEventListener 'mouseclick', (e) =>
            e.stopPropagation()
            @pushEvent e

export nameXOffset = (style) -> style.port_length * 2
export typeNameXOffset = (style) -> nameXOffset style
export typeNameYOffset = (style) -> nameXOffset style
