import {Navigator}      from 'basegl/navigation/Navigator'

import {Breadcrumbs}    from 'view/Breadcrumbs'
import {pushEvent}      from 'view/Component'
import {Connection}     from 'view/Connection'
import {Disposable}     from 'view/Disposable'
import {ExpressionNode} from 'view/ExpressionNode'
import {HalfConnection} from 'view/HalfConnection'
import {InputNode}      from 'view/InputNode'
import {OutputNode}     from 'view/OutputNode'
import {Port}           from 'view/Port'
import {Searcher}       from 'view/Searcher'
import {Visualization}  from 'view/Visualization'


export class NodeEditor extends Disposable
    constructor: (@_scene) ->
        super()
        @nodes ?= {}
        @connections ?= {}
        @visualizations ?= {}
        @inTransaction = false
        @pending = []

    withScene: (fun) =>
        action = => fun @_scene if @_scene?
        if @inTransaction
            @pending.push action
        else
            action()

    beginTransaction: => @inTransaction = true

    commitTransaction: =>
        @inTransaction = false
        for pending in @pending
            pending()
        @pending = []

    initialize: =>
        @withScene (scene) =>
            @controls = new Navigator scene
            @addDisposableListener scene, 'click',     @pushEvent
            @addDisposableListener scene, 'dblclick',  @pushEvent
            @addDisposableListener scene, 'mousedown', @pushEvent
            @addDisposableListener scene, 'mouseup',   @pushEvent

    getMousePosition: => @withScene (scene) =>
        campos = scene.camera.position
        x = (scene.screenMouse.x - scene.width/2) * campos.z + campos.x + scene.width/2
        y = (scene.height/2 - scene.screenMouse.y) * campos.z + campos.y + scene.height/2
        [x, y]

    node: (nodeKey) =>
        node = @nodes[nodeKey]
        if node? then node
        else if @inputNode?  and (@inputNode.key  is nodeKey) then @inputNode
        else if @outputNode? and (@outputNode.key is nodeKey) then @outputNode

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
            nodeView.attach()

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

    setBreadcrumbs: (breadcrumbs) => @genericSetComponent 'breadcrumbs', Breadcrumbs, breadcrumbs
    setInputNode:   (inputNode)   => @genericSetComponent 'inputNode',   InputNode,   inputNode
    setOutputNode:  (outputNode)  => @genericSetComponent 'outputNode',  OutputNode,  outputNode
    setSearcher:    (searcher)    => @genericSetComponent 'searcher',    Searcher,    searcher

    setHalfConnections: (halfConnections) =>
        @genericSetComponents 'halfConnections', HalfConnection, halfConnections

    setVisualization: (nodeVis)   =>
        for vis in nodeVis.visualizations
            vis.nodeKey     = nodeVis.nodeKey
            vis.visualizers = nodeVis.visualizers
            if @visualizations[vis.key]?
                @visualizations[vis.key].set vis
            else
                visView = new Visualization vis, @
                @visualizations[vis.key] = visView
                visView.attach()

    unsetVisualization: (vis) =>
        if @visualizations[vis.key]?
            @visualizations[vis.key].dispose()
            delete @visualizations[vis.key]

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
            connectionView.attach()

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

    genericSetComponent: (name, constructor, value) =>
        if value?
            if @[name]?
                @[name].set value
            else
                @[name] = new constructor value, @
                @[name].attach()
        else
            if @[name]?
                @[name].dispose()
                @[name] = null

    genericSetComponents: (name, constructor, values = []) =>
        @[name] ?= []
        if values.length != @[name].length
            for oldValue in @[name]
                oldValue.dispose()
            @[name] = []
            for value in values
                newValue = new constructor value, @
                @[name].push newValue
                newValue.attach()
        else if values.length > 0
            for i in [0..values.length - 1]
                @[name][i].set value[i]

    destruct: =>
        @breadcrumbs?.dispose()
        @inputNode?.dispose()
        @outputNode?.dispose()
        @searcher?.dispose()
        for connectionKey in Object.keys @connections
            @connections[connectionKey].dispose()
        for nodeKey in Object.keys @nodes
            @nodes[nodeKey].dispose()

    pushEvent: (base) => pushEvent [@constructor.name], base, []
