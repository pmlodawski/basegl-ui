import {Slider}   from 'widget/Slider'
import {Checkbox} from 'widget/Checkbox'
import {Widget}   from 'widget/Widget'


export lookupWidget = (widget) =>
    if widget.cls == 'Bool' then Checkbox
    else if widget.cls == 'Int' then Slider
    else Widget
