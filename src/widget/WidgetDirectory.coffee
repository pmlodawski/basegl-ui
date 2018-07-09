import {ContinousSlider, DiscreteSlider} from 'widget/Slider'
import {Checkbox}                        from 'widget/Checkbox'
import {TextInput}                       from 'widget/TextInput'
import {Widget}                          from 'widget/Widget'


export lookupWidget = (widget) =>
    if widget.cls == 'Bool'      then Checkbox
    else if widget.cls == 'Int'  then DiscreteSlider
    else if widget.cls == 'Real' then ContinousSlider
    else if widget.cls == 'Text' then TextInput
    else Widget
