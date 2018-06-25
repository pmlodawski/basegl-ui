import * as shape from 'shape/port/Base'

import {ContainerComponent} from 'abstract/ContainerComponent'


export class Subport extends ContainerComponent
    registerEvents: (view) =>
        view.addEventListener 'mousedown', (e) => @pushEvent e
        view.addEventListener 'mouseup', (e) => @pushEvent e


export nameXOffset = shape.length * 2
export typeNameXOffset = nameXOffset
export typeNameYOffset = nameXOffset
