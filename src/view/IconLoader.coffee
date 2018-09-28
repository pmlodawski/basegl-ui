import {ContainerComponent} from 'abstract/ContainerComponent'
import * as icons from 'shape/Icon'
import {IconShape}     from 'shape/Icon'

iconRegistry =
    rect: icons.rectIcon
    stripes: icons.stripesIcon
    # add more icons, refactor and extract somewhere else, etc.

export class IconLoader extends ContainerComponent
    initModel: =>
        icon: null
    update: =>
        icon =
            if typeof @model.icon == 'string' || @model.icon instanceof String
                iconRegistry[@model.icon]
            else
                @model.icon
        @autoUpdateDef 'icon', IconShape, if icon then shape: icon

