import {Widget}       from 'widget/Widget'


export class Layout extends Widget
    forEach: (fun) =>
        for own key, def of @__defs
            fun def, key
