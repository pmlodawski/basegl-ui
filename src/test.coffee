require 'babel-core/register'
require 'babel-polyfill'
import * as basegl from 'basegl'
import * as Color     from 'basegl/display/Color'
import {circle}       from 'basegl/display/Shape'
import {vector}       from 'basegl/math/Vector'


node_radius     = 30
width = node_radius * 2 + 50
height = node_radius * 2 + 50

basicNodeShape = basegl.expr ->
    border = 0
    r1     = node_radius + border
    node   = circle r1
    node   = node.move width/2, height/2

compactNodeShape = basegl.expr ->
    node = basicNodeShape
    border = node.grow 15
    border = border.fill Color.rgb [0, 1, 0]
    border + node

# comment compactNodeShape2 to make it work 
compactNodeShape2 = basegl.expr ->
    frame = basicNodeShape.grow 20.0
           .fill Color.rgb [1,0,0]

node = basegl.symbol compactNodeShape
node.variables.selected = 0
node.bbox.xy = [width, height]


export main = ->
    scene = basegl.scene {domElement: 'node-editor-mount'}
    view = scene.add node
    view.addEventListener 'click', (e) => console.log e
