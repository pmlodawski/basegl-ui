import {nodeSelectionBorderMaxSize} from 'shape/node/Base'

export angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle
export distanceFromCenter = nodeSelectionBorderMaxSize
export inArrowRadius    = length + distanceFromCenter
export outArrowRadius    = distanceFromCenter
