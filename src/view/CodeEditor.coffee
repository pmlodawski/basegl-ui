import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape} from 'shape/Html'

import * as style  from 'style'


export class CodeEditor extends ContainerComponent
    initModel: =>
        code: undefined

    prepare: =>
        @addDef 'editor', HtmlShape,
            element: 'div'
            scalable: false
            cssClassName: style.luna ['searcher__root']

    #############################
    ### Create/update the DOM ###
    #############################

    update: =>
        console.log @def('editor')
