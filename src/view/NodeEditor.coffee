import {KeyboardMouseReactor} from 'basegl/navigation/EventReactor'
import {ZoomlessCamera}       from 'basegl/navigation/Camera'

import {Disposable}         from 'abstract/Disposable'
import {EventEmitter}       from 'abstract/EventEmitter'
import {Breadcrumb}         from 'view/Breadcrumb'
import {Connection}         from 'view/Connection'
import {ExpressionNode}     from 'view/ExpressionNode'
import {HalfConnection}     from 'view/HalfConnection'
import {InputNode}          from 'view/InputNode'
import {OutputNode}         from 'view/OutputNode'
import {Styles}             from 'view/Styles'

import * as _ from 'underscore'


export class NodeEditor extends EventEmitter
    cons: (@scene, @mountPointName, @keyboard) ->
        super()

    init: (args...) =>
        super args...
        @nodes                = {}
        @connections          = {}
        @visualizations       = {}
        @visualizerLibraries  = {}
        @topDomScene          = @scene.addDomModel('dom-top')
        @topDomSceneStill     = @scene.addDomModelWithNewCamera('dom-top-still')
        @topDomSceneNoScale   =
            @scene.addDomModelWithNewCamera('dom-top-no-scale', new ZoomlessCamera @scene._camera)
        @mountPoint = document.getElementById(@mountPointName)
        @controls = new KeyboardMouseReactor @scene
        @addDisposableListener @scene, 'click',     (e) => @pushEvent e
        @addDisposableListener @scene, 'dblclick',  (e) => @pushEvent e
        @addDisposableListener @scene, 'mousedown', (e) => @pushEvent e
        @addDisposableListener @scene, 'mouseup',   (e) => @pushEvent e
        @styles = new Styles null, @
        # setTimeout => @styles.set enabled: true

    getMousePosition: =>
        campos = @scene.camera.position
        x = (@scene.screenMouse.x - @scene.width/2) * campos.z + campos.x + @scene.width/2
        y = (@scene.height/2 - @scene.screenMouse.y) * campos.z + campos.y + @scene.height/2
        [x, y]

    node: (nodeKey) =>
        node = @nodes[nodeKey]
        if node? then node
        else if @inputNode?  and (@inputNode.model.key  is nodeKey) then @inputNode
        else if @outputNode? and (@outputNode.model.key is nodeKey) then @outputNode

    unsetNode: (node) =>
        if @nodes[node.key]?
            @nodes[node.key].dispose()
            delete @nodes[node.key]

    setNode: (node) =>
        if @nodes[node.key]?
            @nodes[node.key].set node
        else
            nodeView = new ExpressionNode node, @
            @nodes[node.key] = nodeView

    setNodes: (nodes) =>
        nodeKeys = new Set
        for node in nodes
            nodeKeys.add node.key
        for nodeKey in Object.keys @nodes
            unless nodeKeys.has nodeKey
                @unsetNode @nodes[nodeKey]
        for node in nodes
            @setNode node
        undefined

    setBreadcrumb: (breadcrumb) =>
        @__genericSetComponent 'breadcrumb', Breadcrumb, breadcrumb
    setHalfConnections: (halfConnections) =>
        @__genericSetComponents 'halfConnections', HalfConnection, halfConnections
    setInputNode: (inputNode) =>
        @__genericSetComponent 'inputNode', InputNode, inputNode
    setOutputNode: (outputNode) =>
        @__genericSetComponent 'outputNode', OutputNode, outputNode

    setVisualizerLibraries: (visLib) =>
        unless _.isEqual(@visualizerLibraries, visLib)
            @emitProperty 'visualizerLibraries', visLib

    setVisualization: (nodeVis) =>
        @node(nodeVis.nodeKey)?.set visualizations: nodeVis

    unsetVisualization: (nodeVis) =>
        @node(nodeVis.nodeKey)?.set visualizations: null

    unsetConnection: (connection) =>
        if @connections[connection.key]?
            @connections[connection.key].dispose()
            delete @connections[connection.key]

    setConnection: (connection) =>
        if @connections[connection.key]?
            @connections[connection.key].set connection
        else
            connectionView = new Connection connection, @
            @connections[connection.key] = connectionView

    setConnections: (connections) =>
        connectionKeys = new Set
        for connection in connections
            connectionKeys.add connection.key
        for connectionKey in Object.keys @connections
            unless connectionKeys.has connectionKey
                @unsetConnection @connections[connectionKey]
        for connection in connections
            @setConnection connection
        undefined

    setDebugLayer: (layerNumber) =>
        if layerNumber? and layerNumber >= 0 and layerNumber <= 9
            @scene._symbolRegistry.materials.uniforms.displayMode = layerNumber

    unsetDebugLayer: =>
        @scene._symbolRegistry.materials.uniforms.displayMode = 0

    __genericSetComponent: (name, constructor, value) =>
        if value?
            if @[name]?
                @[name].set value
            else
                @[name] = new constructor value, @
        else
            if @[name]?
                @[name].dispose()
                @[name] = null

    __genericSetComponents: (name, constructor, values = []) =>
        @[name] ?= []
        if values.length != @[name].length
            for oldValue in @[name]
                oldValue.dispose()
            @[name] = []
            for value in values
                newValue = new constructor value, @
                @[name].push newValue
        else if values.length > 0
            for i in [0..values.length - 1]
                @[name][i].set values[i]

    destruct: =>
        @breadcrumb?.dispose()
        @inputNode?.dispose()
        @outputNode?.dispose()
        @searcher?.dispose()
        @visualizerLibraries?.dispose()
        @visualizations?.dispose()
        for connectionKey in Object.keys @connections
            @connections[connectionKey].dispose()
        for nodeKey in Object.keys @nodes
            @nodes[nodeKey].dispose()

    setSearcher: (newSearcher) =>
        if @searcher?.key != newSearcher?.key
            @__unregisterSearcher()
        if newSearcher?
            @keyboard.setContext 'searcher'
            @searcher = newSearcher
            node = @node @searcher.key
            node.set searcher: @searcher
        else
            @keyboard.setContext()

    __unregisterSearcher: =>
        if @searcher?
            node = @node @searcher.key
            @searcher = null
            node?.set searcher: null


    focus: => @mountPoint.focus()

    log: (msg) => console.log "[NodeEditor]", msg

    nodeByName: (name) => #added for debug purposes
        for own k, n of @nodes
            if n.model.name == name
                return n
        return undefined
