root = exports ? this

#Entry point
root.go = ->
  g.ve = new VisualEnvironment(document.getElementById("surface"))
  g.ve.ebox = new ElementBox(g.ve)
  g.ve.surface = new Surface(g.ve)
  g.ve.datgui = null
  g.ve.render(g.ve)

#Global event handlers
root.vz_mousedown = (event) ->
  g.ve.mouseh.ondown(event)

root.swapcontrol = (event) =>
  g.ve.xpcontrol.swapIn()

root.save = () =>
  g.ve.xpcontrol.save()

#Global state holder
g = {}

dsg = "design47"

#Shapes contains a collection of classes that comprise the basic shapes used to
#represent Cypress CPS elements
Shapes = {

  Rectangle : class Rectangle
    constructor: (color, x, y, z, width, height) ->
      @geom = new THREE.PlaneBufferGeometry(width, height)
      @material = new THREE.MeshBasicMaterial({color: color})
      @obj3d = new THREE.Mesh(@geom, @material)
      @obj3d.position.x = x
      @obj3d.position.y = y
      @obj3d.position.z = z
      @obj3d.linep = new THREE.Vector3(x, y, 5)
      @obj3d.lines = []

    select: ->

  Circle : class Circle
    constructor: (color, x, y, z, radius) ->
      @geom = new THREE.CircleGeometry(radius, 64)
      @material = new THREE.MeshBasicMaterial({color: color})
      @obj3d = new THREE.Mesh(@geom, @material)
      @obj3d.position.x = x
      @obj3d.position.y = y
      @obj3d.position.z = z
      @obj3d.linep = new THREE.Vector3(x, y, 5)
      @obj3d.lines = []

    select: ->

  Diamond: class Diamond
    constructor: (color, x, y, z, l) ->
      @shape = new THREE.Shape()
      @shape.moveTo(0,l)
      @shape.lineTo(l,0)
      @shape.lineTo(0,-l)
      @shape.lineTo(-l,0)
      @shape.lineTo(0,l)

      @material = new THREE.MeshBasicMaterial({color: color})
      @geom = new THREE.ShapeGeometry(@shape)
      @obj3d = new THREE.Mesh(@geom, @material)
      @obj3d.position.x = x
      @obj3d.position.y = y
      @obj3d.position.z = z
      @obj3d.linep = new THREE.Vector3(x, y, 5)
      @obj3d.lines = []
    
    select: ->

  Line: class Line
    constructor: (color, from, to, z) ->
      @material = new THREE.LineBasicMaterial({color: color, linewidth: 3})
      @geom = new THREE.Geometry()
      @geom.dynamic = true
      @geom.vertices.push(from, to)
      @obj3d = new THREE.Line(@geom, @material)
      @obj3d.position.x = 0
      @obj3d.position.y = 0
      @obj3d.position.z = z
      @obj3d.lines = []
    
    select: ->

  SelectionCube: class SelectionCube
    constructor: () ->
      @geom = new THREE.Geometry()
      @geom.dynamic = true

      @aa = new THREE.Vector3(0, 0, 75)
      @ab = new THREE.Vector3(0, 0, 75)
      @ba = new THREE.Vector3(0, 0, 75)
      @bb = new THREE.Vector3(0, 0, 75)

      @geom.vertices.push(
        @aa, @ab, @ba,
        @bb, @ba, @ab
      )

      @geom.faces.push(
        new THREE.Face3(0, 1, 2),
        new THREE.Face3(2, 1, 0),
        new THREE.Face3(3, 4, 5),
        new THREE.Face3(5, 4, 3)
      )

      @geom.computeBoundingSphere()
      @material = new THREE.MeshBasicMaterial(
        {
          color: 0x7800ff,
          opacity: 0.2,
          transparent: true
        }
      )
      @obj3d = new THREE.Mesh(@geom, @material)

    updateGFX: () ->
      @geom.verticesNeedUpdate = true
      @geom.lineDistancesNeedUpdate = true
      @geom.elementsNeedUpdate = true
      @geom.normalsNeedUpdate = true
      @geom.computeFaceNormals()
      @geom.computeVertexNormals()
      @geom.computeBoundingSphere()
      @geom.computeBoundingBox()

    init: (p) ->
      @aa.x = @ab.x = @ba.x = p.x
      @aa.y = @ba.y = @ab.y = p.y
      @bb.x = @aa.x
      @bb.y = @aa.y
      @updateGFX()


    update: (p) ->
      @bb.x = @ba.x = p.x
      @bb.y = @ab.y = p.y
      @updateGFX()

    reset: () ->
      @aa.x = @bb.x = @ba.x = @ab.x = 0
      @aa.y = @bb.y = @ba.y = @ab.y = 0
      @updateGFX()

}

#The BaseElements object holds classes which are Visual representations of the
#objects that comprise a Cypress networked CPS system
BaseElements = {
 
  #The Computer class is a representation of a computer
  Computer: class Computer
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Diamond(0x007474, x, y, z, 15)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)
      @props = {
        name: "computer0",
        sys: "root",
        os: "Ubuntu1504-54-STD",
        start_script: ""
        interfaces: {}
      }
      @id = {
        name: "computer0"
        sys: "root"
        design: dsg
      }

    showProps: (f) ->
      c = f.add(@props, 'name')
      c = f.add(@props, 'sys')
      c = f.add(@props, 'start_script')
      c = f.add(@props, 'os')

    links: []


    #cyjs generates the json for this object
    cyjs: ->

  #Router is a visual representation of an IP-network router 
  Router: class Router
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Circle(0x0047ca, x, y, z, 15)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)
      #TODO you are here, all objects with changable props should have a props 
      #object
      @props = {
        name: "router0",
        sys: "root",
        capacity: 100,
        latency: 0
      }
      @id = {
        name: "router0"
        sys: "root"
        design: dsg
      }

    showProps: (f) ->
      f.add(@props, 'name')
      f.add(@props, 'sys')
      f.add(@props, 'capacity')
      f.add(@props, 'latency')
    
    links: []
    
    #cyjs generates the json for this object
    cyjs: ->

  #Switch is a visual representation of an IP-network swtich
  Switch: class Switch
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Rectangle(0x0047ca, x, y, z, 25, 25)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)
      @props = {
        name: "switch0",
        sys: "root",
        capacity: 1000,
        latency: 0
      }
      @id = {
        name: "switch0"
        sys: "root"
        design: dsg
      }

    showProps: (f) ->
      f.add(@props, 'name')
      f.add(@props, 'sys')
      f.add(@props, 'capacity')
      f.add(@props, 'latency')
    
    links: []
    
    #cyjs generates the json for this object
    cyjs: ->

  Link: class Link
    constructor: (@parent, from, to, x, y, z, isIcon = false) ->
      @endpoint = [null, null]
      @ep_ifx = ["",""]
      #TODO: s/ln/shp/g for consistency
      @ln = new Shapes.Line(0xababab, from, to, z)
      @ln.obj3d.userData = this
      @props = {
        name: "link0",
        sys: "root",
        design: dsg,
        capacity: 1000,
        latency: 0,
        endpoints: [
          {name: "", sys: "root", design: dsg, ifname: ""},
          {name: "", sys: "root", design: dsg, ifname: ""}
        ]
      }
      @id = {
        name: "link0"
        sys: "root"
        design: dsg
      }

      #TODO if ln itself is clicked on this messes up selection logic 
      if isIcon
        @shp = new Shapes.Rectangle(@parent.material.color, x, y, z, 25, 25)
        @shp.obj3d.userData = this
        @shp.obj3d.add(@ln.obj3d)
        @parent.obj3d.add(@shp.obj3d)
      else
        @parent.obj3d.add(@ln.obj3d)

    isInternet: ->
      @endpoint[0] instanceof Router and @endpoint[1] instanceof Router

    applyWanProps: ->
      @props.capacity = 100
      @props.latency = 7

    setEndpointData: ->
      @props.endpoints[0].name = @endpoint[0].props.name
      @props.endpoints[0].sys = @endpoint[0].props.sys
      @props.endpoints[0].ifname = @ep_ifx[0]

      @props.endpoints[1].name = @endpoint[1].props.name
      @props.endpoints[1].sys = @endpoint[1].props.sys
      @props.endpoints[1].ifname = @ep_ifx[1]

    ifInternetToWanLink:  ->
      @applyWanProps() if @isInternet()
    
    showProps: (f) ->
      f.add(@props, 'name')
      f.add(@props, 'sys')
      f.add(@props, 'capacity')
      if @isInternet()
        f.add(@props, 'latency')

    #cyjs generates the json for this object
    cyjs: ->

}

#The ElementBox holds Element classes which may be added to a system
class ElementBox
  #Constructs an ElementBox object given a @ve visual environment
  constructor: (@ve) ->
    @height = @ve.height - 10
    @width = 75
    @x = -@ve.width/2  + @width / 2 + 5
    @y =  0
    @z = 5
    @box = new Shapes.Rectangle(0x404040, @x, @y, @z, @width, @height)
    @box.obj3d.userData = this
    @ve.scene.add(@box.obj3d)
    @count = 0
    @addBaseElements()

  #addElement adds a visual element to the ElementBox given an element
  #contruction lambda ef : (box, x, y) -> Object3D
  addElement: (ef) ->
    row = Math.floor(@count / 2)
    col = @count % 2

    _x = if col == 0 then -18 else 18
    _y = (@ve.height / 2 - 25) - row * 35
    ef(@box, _x, _y)
    @count++

  #addBaseElements adds the common base elements to the ElementBox
  addBaseElements: ->
    @addElement((box, x, y) -> new BaseElements.Computer(box, x, y, 5))
    @addElement((box, x, y) -> new BaseElements.Router(box, x, y, 5))
    @addElement((box, x, y) -> new BaseElements.Switch(box, x, y, 5))
    @addElement((box, x, y) ->
      new BaseElements.Link(box,
        new THREE.Vector3(-12.5, 12.5, 5), new THREE.Vector3(12.5, -12.5, 5),
        x, y, 5, true
      )
    )

#The Surface holds visual representations of Systems and Elements
class Surface
  #Constructs a Surface object given a @ve visual environment
  constructor: (@ve) ->
    @height = @ve.height
    @width = @ve.width
    @baseRect = new Shapes.Rectangle(0x262626, 0, 0, 0, @width, @height)
    @baseRect.obj3d.userData = this
    @ve.scene.add(@baseRect.obj3d)
    @selectGroup = new THREE.Group()
    @ve.scene.add(@selectGroup)
    @selectorGroup = new THREE.Group()
    @ve.scene.add(@selectorGroup)
    @elements = []

  addElement: (ef, x, y) ->
    e = new ef.constructor(@baseRect, x, y, 50)
    e.props.name = @ve.namemanager.getName(e.constructor.name.toLowerCase())
    e.id.name = e.props.name
    e.props.design = dsg
    @elements.push(e)
    @ve.render()
    e

  addIfContains: (box, e, set) ->
    o3d = null
    if e.shp?
      o3d = e.shp.obj3d
    else if e.ln?
      o3d = e.ln.obj3d
    if o3d != null
      o3d.geometry.computeBoundingBox()
      bb = o3d.geometry.boundingBox
      bx = new THREE.Box2(
        o3d.localToWorld(bb.min),
        o3d.localToWorld(bb.max)
      )
      set.push(e) if box.containsBox(bx)

      #for some reason computing the bounding box kills selection
      o3d.geometry.boundingBox = null
    true

  toBox2: (box) ->
    new THREE.Box2(
      new THREE.Vector2(box.min.x, box.min.y),
      new THREE.Vector2(box.max.x, box.max.y)
    )

  getSelection: (box) ->
    xs = []
    box2 = @toBox2(box)
    @addIfContains(box2, x, xs) for x in @elements
    xs

  
  updateLink: (ln) ->
    ln.geom.verticesNeedUpdate = true
    ln.geom.lineDistancesNeedUpdate = true
    ln.geom.elementsNeedUpdate = true
    ln.geom.normalsNeedUpdate = true
    ln.geom.computeFaceNormals()
    ln.geom.computeVertexNormals()
    ln.geom.computeBoundingSphere()
    ln.geom.computeBoundingBox()

  moveObject: (o, p) ->
    o.position.x = p.x
    o.position.y = p.y
    o.linep.x = p.x
    o.linep.y = p.y

    if o.userData.glowBubble?
      o.userData.glowBubble.position.x = p.x
      o.userData.glowBubble.position.y = p.y

    @updateLink(ln) for ln in o.lines
    true

  moveSelection: -> #TODO
  
  glowMaterial: () ->
    cam = @.ve.camera
    new THREE.ShaderMaterial({
      uniforms: {
          "c": { type: "f", value: 1.0 },
          "p": { type: "f", value: 1.4 },
          glowColor: { type: "c", value: new THREE.Color(0x7800ff) },
          viewVector: { type: "v3", value: cam.position }
      },
      vertexShader: document.getElementById("vertexShader").textContent,
      fragmentShader: document.getElementById("fragmentShader").textContent,
      side: THREE.FrontSide,
      blending: THREE.AdditiveBlending,
      transparent: true
    })

  glowSphere: (radius, x, y, z) ->
    geom = new THREE.SphereGeometry(radius, 64, 64)
    mat = @glowMaterial()
    obj = new THREE.Mesh(geom, mat)
    obj.position.x = x
    obj.position.y = y
    obj.position.z = z
    obj

  glowCube: (width, height, depth, x, y, z) ->
    geom = new THREE.BoxGeometry(width, height, depth, 2, 2, 2)
    mat = @glowMaterial()
    obj = new THREE.Mesh(geom, mat)
    obj.position.x = x
    obj.position.y = y
    obj.position.z = z
    modifier = new THREE.SubdivisionModifier(2)
    modifier.modify(geom)
    obj

  glowDiamond: (w, h, d, x, y, z) ->
    obj = @glowCube(w, h, d, x, y, z)
    obj.rotateZ(Math.PI/4)
    obj

  clearPropsGUI: ->
    if @ve.datgui?
      @ve.datgui.destroy()
      @ve.datgui = null

  showPropsGUI: (s) ->
    @ve.datgui = new dat.GUI()

    addElem = (d, k, v) ->
      if !d[k]?
        d[k] = [v]
      else
        d[k].push(v)

    dict = new Array()
    addElem(dict, x.constructor.name, x) for x in s

    addGuiElems = (typ, xs) =>
      f = @ve.datgui.addFolder(typ)
      x.showProps(f) for x in xs
      f.open()

    addGuiElems(k, v) for k,v of dict

    $(@ve.datgui.domElement).focusout () =>
      @ve.addie.update(x) for x in s

    true

  selectObj: (obj) ->

    if not obj.glowBubble?
      if obj.shp instanceof Shapes.Circle
        p = obj.shp.obj3d.position
        s = obj.shp.geom.boundingSphere.radius + 3
        gs = @glowSphere(s, p.x, p.y, p.z)
      else if obj.shp instanceof Shapes.Rectangle
        p = obj.shp.obj3d.position
        s = obj.shp.geom.boundingSphere.radius + 3
        l = s*1.5
        gs = @glowCube(l, l, l, p.x, p.y, p.z)
      else if obj.shp instanceof Shapes.Diamond
        p = obj.shp.obj3d.position
        s = obj.shp.geom.boundingSphere.radius + 3
        l = s*1.5
        gs = @glowDiamond(l, l, l, p.x, p.y, p.z)
      else if obj.ln instanceof Shapes.Line
        d = 10
        h = 10
        v0 = obj.ln.geom.vertices[0]
        v1 = obj.ln.geom.vertices[obj.ln.geom.vertices.length - 1]
        w = obj.ln.geom.boundingSphere.radius * 2
        x = (v0.x + v1.x) / 2
        y = (v0.y + v1.y) / 2
        z = 5
        gs = @glowCube(w, h, d, x, y, z)
        theta = Math.atan2(v0.y - v1.y, v0.x - v1.x)
        gs.rotateZ(theta)
      else
        console.log "unkown object to select"
        console.log obj

      gs.userData = obj
      obj.glowBubble = gs
      @selectGroup.add(gs)
      @ve.render()
    true

  clearSelection: ->
    delete gb.userData.glowBubble for gb in @selectGroup.children
    @selectGroup.children = []
    @clearPropsGUI()
    @ve.render()

  clearSelector: ->
    @selectorGroup.children = []
    @ve.render()

class NameManager
  constructor: () ->
    @names = new Array()

  getName: (s) ->
    if !@names[s]?
      @names[s] = 0
    else
      @names[s]++

    s + @names[s]

#TODO you are here
class ExperimentControl
  constructor: (@ve) ->
  
  expJson: ->
    console.log "Generating experiment json for " + @ve.surface.elements.length +
      " elements"

    data = {
      computers: [],
      routers: [],
      switches: [],
      lan_links: [],
      wan_links: []
    }

    linkAdd = (l) ->
      switch
        when l.isInternet() then data.wan_links.push(l.props)
        else data.lan_links.push(l.props)

    add = (e) ->
      switch
        when e instanceof BaseElements.Computer then data.computers.push(e.props)
        when e instanceof BaseElements.Router then data.routers.push(e.props)
        when e instanceof BaseElements.Switch then data.switches.push(e.props)
        when e instanceof BaseElements.Link then linkAdd(e)
        else console.log('unkown element -- ', e)

    add(e) for e in @ve.surface.elements

    console.log(data)
    console.log(JSON.stringify(data, null, 2))

    data

  save: ->
    console.log("saving experiment")

    console.log("to the bakery!")

    console.log("getting")
    $.get "addie/bakery", (data) =>
      console.log("bakery GET")
      console.log(data)
    
    console.log("posting")
    $.post "addie/bakery", (data) =>
      console.log("bakery POST")
      console.log(data)

  swapIn: ->
    @expJson()

  swapOut: ->

  update: ->


#VisualEnvironment holds the state associated with the Threejs objects used
#to render Surfaces and the ElementBox. This class also contains methods
#for controlling and interacting with this group of Threejs objects.
class VisualEnvironment

  #Constructs a visual environment for the given @container. @container must
  #be a reference to a <div> dom element. The Threejs canvas the visual 
  #environment renders onto will be appended as a child of the supplied 
  #container
  constructor: (@container) ->
    @scene = new THREE.Scene()
    @width = @container.offsetWidth
    @height = @container.offsetHeight
    @camera = new THREE.OrthographicCamera(
      @width / -2, @width / 2,
      @height / 2, @height / -2,
      1, 1000)
    @renderer = new THREE.WebGLRenderer({antialias: true, alpha: true})
    @renderer.setSize(@width, @height)
    @clear = 0x262626
    @alpha = 1
    @renderer.setClearColor(@clear, @alpha)
    @container.appendChild(@renderer.domElement)
    @camera.position.z = 200
    @mouseh = new MouseHandler(this)
    @raycaster = new THREE.Raycaster()
    @raycaster.linePrecision = 10
    @namemanager = new NameManager()
    @xpcontrol = new ExperimentControl(this)
    @addie = new Addie(this)
    @propsEditor = new PropsEditor(this)

  render: ->
    @renderer.clear()
    @renderer.clearDepth()
    @renderer.render(@scene, @camera)


#This is the client side Addie, it talks to the Addie at cypress.deterlab.net
#to manage a design
class Addie
  constructor: (@ve) ->

  update: (x) =>
    console.log("updating object")
    console.log(x)
    
    msg = { Elements: [] }
    
    if x.shp?
      x.props.position = x.shp.obj3d.position

    ido = { OID: x.id, Type: x.constructor.name, Element: x.props }
    msg.Elements.push(ido)


    if x.setEndpointData?
      x.setEndpointData()
      ep = x.endpoint[0]
      msg.Elements.push(
        { OID: ep.id, Type: ep.constructor.name, Element: ep.props }
      )
      ep = x.endpoint[1]
      msg.Elements.push(
        { OID: ep.id, Type: ep.constructor.name, Element: ep.props }
      )

    console.log(msg)
    $.post "/addie/"+dsg+"/design/update", JSON.stringify(msg), (data) =>
      x.id.name = x.props.name
      x.id.sys = x.props.sys

    updateLink = (l) =>
      l.setEndpointData()
      @update(l)


    if x.links?
      updateLink(l) for l in x.links

    true

  updates: (xs) =>
    console.log("updating objects")
    console.log(xs)

    msg = { Elements: [] }

    for x in xs
      if x.shp?
        x.props.position = x.shp.obj3d.position
        ido = { OID: x.id, Type: x.constructor.name, Element: x.props }
        msg.Elements.push(ido)

      if x.links?
        updateLink(l) for l in x.links

      true

    console.log(msg)
    
    $.post "/addie/"+dsg+"/design/update", JSON.stringify(msg), (data) =>
      for x in xs
        x.id.name = x.props.name
        x.id.sys = x.props.sys


class EBoxSelectHandler
  constructor: (@mh) ->

  test: (ixs) ->
    ixs.length > 2 and
    ixs[ixs.length - 2].object.userData instanceof ElementBox and
    ixs[0].object.userData.cyjs?

  handleDown: (ixs) ->
    e = ixs[0].object.userData
    console.log "! ebox select -- " + e.constructor.name
    console.log e
    #TODO double click should lock linking until link icon clicked again
    #     this way many things may be linked without going back to the icon
    if e instanceof Link
      console.log "! linking objects"
      @mh.ve.container.onmousemove = (eve) => @mh.linkingH.handleMove0(eve)
      @mh.ve.container.onmousedown = (eve) => @mh.linkingH.handleDown0(eve)
    else
      console.log "! placing objects"
      @mh.makePlacingObject(e)
      @mh.ve.container.onmousemove = (eve) => @handleMove(eve)
      @mh.ve.container.onmouseup = (eve) => @handleUp(eve)

  handleUp: (event) ->
    @mh.ve.addie.update(@mh.placingObject)

    @mh.ve.container.onmousemove = null
    @mh.ve.container.onmousedown = (eve) => @mh.baseDown(eve)
    @mh.ve.container.onmouseup = null

  handleMove: (event) ->
    @mh.updateMouse(event)

    @mh.ve.raycaster.setFromCamera(@mh.pos, @mh.ve.camera)
    bix = @mh.ve.raycaster.intersectObject(@mh.ve.surface.baseRect.obj3d)

    if bix.length > 0
      ox = @mh.placingObject.shp.geom.boundingSphere.radius
      @mh.ve.surface.moveObject(@mh.placingObject.shp.obj3d, bix[0].point)
      @mh.ve.render()

class SurfaceElementSelectHandler
  constructor: (@mh) ->

  test: (ixs) ->
    ixs.length > 1 and
    ixs[ixs.length - 1].object.userData instanceof Surface and
    ixs[0].object.userData.cyjs?

  handleDown: (ixs) ->
    e = ixs[0].object.userData
    console.log "! surface select -- " + e.constructor.name
    @mh.ve.surface.clearSelection()
    @mh.ve.surface.selectObj(e)
    @mh.ve.propsEditor.elements = [e]
    @mh.ve.propsEditor.show()
    @mh.placingObject = e
    @mh.ve.container.onmouseup = (eve) => @handleUp(eve)
    @mh.ve.container.onmousemove = (eve) => @handleMove(eve)
  
  handleUp: (ixs) ->
    @mh.ve.addie.update(@mh.placingObject)

    @mh.ve.container.onmousemove = null
    @mh.ve.container.onmousedown = (eve) => @mh.baseDown(eve)
    @mh.ve.container.onmouseup = null
  
  handleMove: (event) ->
    @mh.updateMouse(event)

    @mh.ve.raycaster.setFromCamera(@mh.pos, @mh.ve.camera)
    bix = @mh.ve.raycaster.intersectObject(@mh.ve.surface.baseRect.obj3d)

    if bix.length > 0
      ox = @mh.placingObject.shp.geom.boundingSphere.radius
      @mh.ve.surface.moveObject(@mh.placingObject.shp.obj3d, bix[0].point)
      @mh.ve.render()


class PropsEditor
  constructor: (@ve) ->
    @elements = []
    @cprops = {}

  show: () ->
    @commonProps()
    @datgui = new dat.GUI()
    for k, v of @cprops
      @datgui.add(@cprops, k)

    $(@datgui.domElement).focusout () =>
      for k, v of @cprops
        for e in @elements
          e.props[k] = v
          @ve.addie.update(e)
      true

    true

  hide: () ->
    if @datgui?
      @datgui.destroy()
      @datgui = null

  commonProps: () ->
    
    ps = {}
    cps = new Array()

    addProp = (d, k, v) ->
      if !d[k]?
        d[k] = [v]
      else
        d[k].push(v)

    addProps = (e) =>
      for k, v of e.props
        continue if k == 'position'
        continue if k == 'design'
        continue if k == 'endpoints'
        continue if k == 'interfaces'
        continue if k == 'name' and @elements.length > 1
        addProp(ps, k, v)

    addProps(e) for e in @elements

    addCommon = (k, v, es) ->
      if v.length == es.length then cps[k] = v
      true

    addCommon(k, v, @elements) for k, v of ps

    isUniform = (xs) ->
      u = true
      i = xs[0]
      for x in xs
        u = (x == i)
        break if !u
      u

    setUniform = (k, v, e) ->
      if isUniform(v)
        e[k] = v[0]
      else
        e[k] = ""
      true

    reduceUniform = (xps) ->
      setUniform(k, v, xps) for k, v of xps
      true

    reduceUniform(cps)

    @cprops = cps
    cps


class SurfaceSpaceSelectHandler
  constructor: (@mh) ->
    @selCube = new SelectionCube()

  test: (ixs) ->
    ixs.length > 0 and
    ixs[0].object.userData instanceof Surface

  handleDown: (ixs) ->
    console.log "! space select down"
    p = new THREE.Vector3(
      ixs[ixs.length - 1].point.x,
      ixs[ixs.length - 1].point.y,
      75
    )
    @selCube.init(p)
    @mh.ve.container.onmouseup = (eve) => @handleUp(eve)
    @mh.ve.surface.selectorGroup.add(@selCube.obj3d)
    @mh.ve.container.onmousemove = (eve) => @handleMove(eve)
    @mh.ve.surface.clearSelection()

  handleUp: (event) ->
    console.log "! space select up"
    sel = @mh.ve.surface.getSelection(@selCube.obj3d.geometry.boundingBox)
    @mh.ve.surface.selectObj(o) for o in sel
    @mh.ve.propsEditor.elements = sel
    console.log('common props')
    @mh.ve.propsEditor.show()
    @selCube.reset()
    @mh.ve.container.onmousemove = null
    @mh.ve.container.onmousedown = (eve) => @mh.baseDown(eve)
    @mh.ve.container.onmouseup = null
    @mh.ve.surface.clearSelector()
    @mh.ve.render()

  handleMove: (event) ->
    bix = @mh.baseRectIx(event)
    if bix.length > 0
      p = new THREE.Vector3(
        bix[bix.length - 1].point.x,
        bix[bix.length - 1].point.y,
        75
      )
      @selCube.update(p)
      @mh.ve.render()
    

class LinkingHandler
  constructor: (@mh) ->

  handleDown0: (event) ->
    @mh.ve.raycaster.setFromCamera(@mh.pos, @mh.ve.camera)
    ixs = @mh.ve.raycaster.intersectObjects(
              @mh.ve.surface.baseRect.obj3d.children)

    if ixs.length > 0 and ixs[0].object.userData.cyjs?
      e = ixs[0].object.userData
      console.log "! lnk0 " + e.constructor.name
      pos0 = ixs[0].object.linep
      pos1 = new THREE.Vector3(
        ixs[0].object.position.x,
        ixs[0].object.position.y,
        5
      )

      @mh.placingLink = new BaseElements.Link(@mh.ve.surface.baseRect,
        pos0, pos1, 0, 0, 5
      )
      @mh.ve.surface.elements.push(@mh.placingLink)
      @mh.placingLink.props.name = @mh.ve.namemanager.getName("lnk")
      
      ifname = ""
      if ixs[0].object.userData.props.interfaces?
        ifname = "ifx"+Object.keys(ixs[0].object.userData.props.interfaces).length
        ixs[0].object.userData.props.interfaces[ifname] = {
          name: ifname,
          latency: 0,
          capacity: 1000
        }
      @mh.placingLink.endpoint[0] = ixs[0].object.userData
      @mh.placingLink.ep_ifx[0] = ifname
      @mh.placingLink.endpoint[0].links.push(@mh.placingLink)
      ixs[0].object.lines.push(@mh.placingLink.ln)
      @mh.ve.container.onmousemove = (eve) => @handleMove1(eve)
      @mh.ve.container.onmousedown = (eve) => @handleDown1(eve)
    else
      console.log "! lnk0 miss"

  handleDown1: (event) ->
    @mh.ve.raycaster.setFromCamera(@mh.pos, @mh.ve.camera)
    ixs = @mh.ve.raycaster.intersectObjects(
                @mh.ve.surface.baseRect.obj3d.children)
    if ixs.length > 0 and ixs[0].object.userData.cyjs?
      e = ixs[0].object.userData
      console.log "! lnk1 " + e.constructor.name
      @mh.placingLink.ln.geom.vertices[1] = ixs[0].object.linep
      ixs[0].object.lines.push(@mh.placingLink.ln)
      
      ifname = ""
      if ixs[0].object.userData.props.interfaces?
        ifname = "ifx"+Object.keys(ixs[0].object.userData.props.interfaces).length
        ixs[0].object.userData.props.interfaces[ifname] = {
          name: ifname,
          latency: 0,
          capacity: 1000
        }
      @mh.placingLink.endpoint[1] = ixs[0].object.userData
      @mh.placingLink.ep_ifx[1] = ifname
      @mh.placingLink.endpoint[1].links.push(@mh.placingLink)

      @mh.ve.surface.updateLink(@mh.placingLink.ln)
      @mh.placingLink.ifInternetToWanLink()
      @mh.placingLink.setEndpointData()

      @mh.ve.addie.update(@mh.placingLink)


      @mh.ve.container.onmousemove = null
      @mh.ve.container.onmousedown = (eve) => @mh.baseDown(eve)
    else
      console.log "! lnk1 miss"

  handleMove0: (event) ->
    @.mh.updateMouse(event)
    #console.log "! lm0"
    
  handleMove1: (event) ->
    #TODO replace me with baseRectIx when that is ready
    @.mh.updateMouse(event)
    @.mh.ve.raycaster.setFromCamera(@.mh.pos, @.mh.ve.camera)
    bix = @.mh.ve.raycaster.intersectObject(@.mh.ve.surface.baseRect.obj3d)
    if bix.length > 0
      #console.log "! lm1"
      @.mh.ve.scene.updateMatrixWorld()
      @.mh.placingLink.ln.geom.vertices[1].x = bix[bix.length - 1].point.x
      @.mh.placingLink.ln.geom.vertices[1].y = bix[bix.length - 1].point.y
      @.mh.placingLink.ln.geom.verticesNeedUpdate = true
      @.mh.ve.render()

#Mouse handler encapsulates the logic of dealing with mouse events
class MouseHandler

  constructor: (@ve) ->
    @pos = new THREE.Vector3(0, 0, 1)
    @eboxSH = new EBoxSelectHandler(this)
    @surfaceESH = new SurfaceElementSelectHandler(this)
    @surfaceSSH = new SurfaceSpaceSelectHandler(this)
    @linkingH = new LinkingHandler(this)

  ondown: (event) -> @baseDown(event)
  
  updateMouse: (event) ->
    @pos.x =  (event.layerX / @ve.container.offsetWidth ) * 2 - 1
    @pos.y = -(event.layerY / @ve.container.offsetHeight) * 2 + 1
    #console.log(@pos.x + "," + @pos.y)

  baseRectIx: (event) ->
    @updateMouse(event)
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    @ve.raycaster.intersectObject(@ve.surface.baseRect.obj3d)

  placingObject: null
  placingLink: null
  
  makePlacingObject: (obj) ->
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    bix = @ve.raycaster.intersectObject(@ve.surface.baseRect.obj3d)
    x = y = 0
    if bix.length > 0
      ix = bix[bix.length - 1]
      x = ix.point.x
      y = ix.point.y

    @placingObject = @ve.surface.addElement(obj, x, y)

  #onmousedown handlers
  baseDown: (event) ->

    @ve.propsEditor.hide()

    #get the list of objects the mouse click intersected
    #@ve.scene.updateMatrixWorld()
    @updateMouse(event)
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    ixs = @ve.raycaster.intersectObjects(@ve.scene.children, true)

    #delegate the handling of the event to one of the handlers
    if      @eboxSH.test(ixs) then @eboxSH.handleDown(ixs)
    else if @surfaceESH.test(ixs) then @surfaceESH.handleDown(ixs)
    else if @surfaceSSH.test(ixs) then @surfaceSSH.handleDown(ixs)

    true



