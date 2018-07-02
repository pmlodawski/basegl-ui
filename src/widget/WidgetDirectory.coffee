import {Slider}    from 'widget/Slider'
import {Checkbox}  from 'widget/Checkbox'
import {TextInput} from 'widget/TextInput'
import {Widget}    from 'widget/Widget'


export lookupWidget = (widget) =>
    if widget.cls == 'Bool' then Checkbox
    else if widget.cls == 'Int' then Slider
    else if widget.cls == 'String' then TextInput
    else Widget
