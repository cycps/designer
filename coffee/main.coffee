root = exports ? this

#Entry point
root.go = ->
  g.ve = new VisualEnvironment(document.getElementById("surface"))
  g.ve.ebox = new ElementBox(g.ve)
  g.ve.surface = new Surface(g.ve)
  g.ve.render(g.ve)

#Global event handlers
root.vz_mousedown = (event) ->
  g.ve.mouseh.ondown(event)

#Global state holder
g = {}

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

  Circle : class Circle
    constructor: (color, x, y, z, radius) ->
      @geom = new THREE.CircleGeometry(radius, 64)
      @material = new THREE.MeshBasicMaterial({color: color})
      @obj3d = new THREE.Mesh(@geom, @material)
      @obj3d.position.x = x
      @obj3d.position.y = y
      @obj3d.position.z = z

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

}

#The BaseElements object holds classes which are Visual representations of the
#objects that comprise a Cypress networked CPS system
BaseElements = {
 
  #The Controller class is a visual representation of a controller e.g., a
  #computer that hosts control code
  Controller: class Controller
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Diamond(0x007474, x, y, z, 15)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)

    #cyjs generates the json for this object
    cyjs: ->

  #Router is a visual representation of an IP-network router 
  Router: class Router
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Circle(0x0047ca, x, y, z, 15)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)
    
    #cyjs generates the json for this object
    cyjs: ->

  #Switch is a visual representation of an IP-network swtich
  Switch: class Switch
    constructor: (@parent, x, y, z) ->
      @shp = new Shapes.Rectangle(0x0047ca, x, y, z, 25, 25)
      @shp.obj3d.userData = this
      @parent.obj3d.add(@shp.obj3d)
    
    #cyjs generates the json for this object
    cyjs: ->

  Link: class Link
    constructor: (@parent, from, to, x, y, z, isIcon = false) ->
      @ln = new Shapes.Line(0xababab, from, to, z)
      @ln.obj3d.userData = this

      #TODO if ln itself is clicked on this messes up selection logic 
      if isIcon
        @shp = new Shapes.Rectangle(@parent.material.color, x, y, z, 25, 25)
        @shp.obj3d.userData = this
        @shp.obj3d.add(@ln.obj3d)
        @parent.obj3d.add(@shp.obj3d)
      else
        @parent.obj3d.add(@ln.obj3d)

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
    @addElement((box, x, y) -> new BaseElements.Controller(box, x, y, 5))
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

  addElement: (ef, x, y) ->
    e = new ef.constructor(@baseRect, x, y, 50)
    @ve.render()
    e

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
    @width = container.offsetWidth
    @height = container.offsetHeight
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
    @camera.position.z = 100
    @mouseh = new MouseHandler(this)
    @raycaster = new THREE.Raycaster()

  render: ->
    @renderer.clear()
    @renderer.clearDepth()
    @renderer.render(@scene, @camera)

#Mouse handler encapsulates the logic of dealing with mouse events
class MouseHandler

  constructor: (@ve) ->
    @pos = new THREE.Vector2(0, 0)

  ondown: (event) -> @baseDown(event)
  
  updateMouse: (event) ->
    @pos.x =  (event.layerX / @ve.container.offsetWidth ) * 2 - 1
    @pos.y = -(event.layerY / @ve.container.offsetHeight) * 2 + 1
    #console.log(@pos.x + "," + @pos.y)

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
    @updateMouse(event)
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    ixs = @ve.raycaster.intersectObjects(@ve.scene.children, true)
    if ixs.length > 1 and
      ixs[1].object.userData instanceof ElementBox and
      ixs[0].object.userData.cyjs?
        e = ixs[0].object.userData
        console.log "! ebox select -- " + e.constructor.name
        console.log e
        if e instanceof Link
          console.log "! linking objects"
          @ve.container.onmousemove = (eve) => @linkingMove0(eve)
          @ve.container.onmousedown = (eve) => @linkingDown0(eve)
        else
          console.log "! placing objects"
          @makePlacingObject(e)
          @ve.container.onmousemove = (eve) => @placingMove(eve)
          @ve.container.onmousedown = (eve) => @placingDown(eve)

    if ixs.length > 1 and
      ixs[1].object.userData instanceof Surface and
      ixs[0].object.userData.cyjs?
        e = ixs[0].object.userData
        console.log "! surface select -- " + e.constructor.name
        console.log e
        @placingObject = e
        @ve.container.onmousemove = (eve) => @placingMove(eve)
        @ve.container.onmousedown = (eve) => @placingDown(eve)

  placingDown: (event) ->
    console.log "plop"
    @ve.container.onmousemove = null
    @ve.container.onmousedown = (eve) => @baseDown(eve)

  linkingDown0: (event) ->
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    ixs = @ve.raycaster.intersectObjects(@ve.surface.baseRect.obj3d.children)
    if ixs.length > 0 and ixs[0].object.userData.cyjs?
      e = ixs[0].object.userData
      console.log "! lnk0 " + e.constructor.name
      pos0 = new THREE.Vector3(
        ixs[0].object.position.x,
        ixs[0].object.position.y,
        5
      )
      pos1 = new THREE.Vector3(
        ixs[0].object.position.x,
        ixs[0].object.position.y,
        5
      )
      @placingLink = new BaseElements.Link(@ve.surface.baseRect,
        pos0, pos1, 0, 0, 5
      )
      @ve.container.onmousemove = (eve) => @linkingMove1(eve)
      @ve.container.onmousedown = (eve) => @linkingDown1(eve)
    else
      console.log "! lnk0 miss"


  linkingDown1: (event) ->
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    ixs = @ve.raycaster.intersectObjects(@ve.surface.baseRect.obj3d.children)
    if ixs.length > 0 and ixs[0].object.userData.cyjs?
      e = ixs[0].object.userData
      console.log "! lnk1 " + e.constructor.name
      @ve.container.onmousemove = null
      @ve.container.onmousedown = (eve) => @baseDown(eve)
    else
      console.log "! lnk1 miss"

  #onmousemove handlers
  placingMove: (event) ->
    @updateMouse(event)

    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    bix = @ve.raycaster.intersectObject(@ve.surface.baseRect.obj3d)

    if bix.length > 0
      ox = @placingObject.shp.geom.boundingSphere.radius
      @placingObject.shp.obj3d.position.x = bix[0].point.x
      @placingObject.shp.obj3d.position.y = bix[0].point.y
      @ve.render()

  linkingMove0: (event) ->
    @updateMouse(event)
    #console.log "! lm0"
    
  linkingMove1: (event) ->
    @updateMouse(event)
    @ve.raycaster.setFromCamera(@pos, @ve.camera)
    bix = @ve.raycaster.intersectObject(@ve.surface.baseRect.obj3d)
    if bix.length > 0
      #console.log "! lm1"
      @ve.scene.updateMatrixWorld()
      @placingLink.ln.geom.vertices[1].x = bix[bix.length - 1].point.x
      @placingLink.ln.geom.vertices[1].y = bix[bix.length - 1].point.y
      @placingLink.ln.geom.verticesNeedUpdate = true
      @ve.render()

