import 'dart:html';
import 'dart:math' as math;
import 'package:js/js.dart';
import 'package:threejs_facade/three.dart';
import 'package:threejs_facade/controls/trackball_controls.dart';
import 'package:threejs_facade/renderers/canvas_renderer.dart';

/*
	Three.js "tutorials by example"
	Author: Lee Stemkoski
	Date: July 2013 (three.js v59dev)
*/

DivElement container;

void main() {
  init();
  animate(null);
}

Scene scene;
PerspectiveCamera camera;
Renderer renderer;
TrackballControls controls;
const webgl = true;
// const webgl = false; // issues

num zFunc(num x, num y) => math.sin(math.sqrt(math.pow(x, 2) + math.pow(y, 2)));

// var meshFunction;
var segments = 400;
var xMin = -10;
var xMax = 10;
var yMin = -10;
var yMax = 10;
var zMin = -10;
var zMax = 10;

var xRange = xMax - xMin;
var yRange = yMax - yMin;
var zRange = zMax - zMin;

// ParametricGeometry graphGeometry;
// var gridMaterial;
MeshBasicMaterial wireMaterial;
MeshBasicMaterial vertexColorMaterial;
Mesh graphMesh;

void onWindowResize(_) {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

void init() {
  container = querySelector('#container');
  scene = new Scene();
  var width = container.clientWidth;
  var height = container.clientHeight;
  var viewAngle = 45;
  var near = 0.1;
  var far = 2000;
  var aspect = width / height;
  camera = new PerspectiveCamera(viewAngle, aspect, near, far);
  camera.up = new Vector3(0, 0, 1);
  camera.lookAt(scene.position);
  scene.add(camera);
  // camera.position.set(0, 150, 400);
  // camera.lookAt(scene.position);

  // renderer
  if (webgl) {
  	renderer = new WebGLRenderer(
      new WebGLRendererParameters()..antialias=true);
  } else {
  	renderer = new CanvasRenderer();
  }
  renderer.setSize(width, height);

  container.append(renderer.domElement);
  // events
  window.onResize.listen(onWindowResize);

  // controls
  controls = new TrackballControls(camera, renderer.domElement);

  // light
  var light = new PointLight(new Color(0xffffff));
  light.position.set(0, 250, 0);
  scene.add(light);
  // fog
  // scene.fog = new FogExp2( 0x888888, 0.025 );

  ////////////
  // CUSTOM //
  ////////////

  scene.add(new AxisHelper());

  // wireframe for xy-plane
  // var wireframeMaterial = new MeshBasicMaterial()
  //   ..color = new Color(0x000088)
  //   ..wireframe = true
  //   ..side = DoubleSide;

  // var grid = new GridHelper(20, 20, new Color(0x000088), new Color(0xff0000));
  // grid.rotation.x = math.PI/2;
  // scene.add(grid);

  var polarGrid = new PolarGridHelper(10, 20, 20, 100, new Color(0x000088), new Color(0xff0000));
  polarGrid.rotation.x = math.PI/2;
  scene.add(polarGrid);

  // shadeMaterial = new MeshLambertMaterial()
  // 	..color = new Color(0xff0000);

  // "wireframe texture"
  var wireTexture = new TextureLoader().load('images/white.png');
  wireTexture.wrapS = wireTexture.wrapT = RepeatWrapping;
  wireTexture.repeat.set(40, 40);

  wireMaterial = new MeshBasicMaterial()
    ..map = wireTexture
    ..vertexColors = VertexColors
    ..side = DoubleSide;

  vertexColorMaterial = new MeshBasicMaterial()..vertexColors = VertexColors;
  // bgcolor
  renderer.setClearColor(new Color(0x888888), 1);

  ///////////////////
  //   GUI SETUP   //
  ///////////////////

  // gui = new dat.GUI();
  //
  // parameters =
  // {
  // 	resetCam:  function() { resetCamera(); },
  // 	preset1:   function() { preset01(); },
  // 	graphFunc: function() { createGraph(); },
  // 	finalValue: 337
  // };
  //
  // // GUI -- equation
  // gui_zText = gui.add( this, 'zFuncText' ).name('z = f(x,y) = ');
  // gui_xMin = gui.add( this, 'xMin' ).name('x Minimum = ');
  // gui_xMax = gui.add( this, 'xMax' ).name('x Maximum = ');
  // gui_yMin = gui.add( this, 'yMin' ).name('y Minimum = ');
  // gui_yMax = gui.add( this, 'yMax' ).name('y Maximum = ');
  // gui_segments = gui.add( this, 'segments' ).name('Subdivisions = ');
  //
  // // GUI -- parameters
  // var gui_parameters = gui.addFolder('Parameters');
  // a = b = c = d = 0.01;
  // gui_a = gui_parameters.add( this, 'a' ).min(-5).max(5).step(0.01).name('a = ');
  // gui_a.onChange( function(value) { createGraph(); } );
  // gui_b = gui_parameters.add( this, 'b' ).min(-5).max(5).step(0.01).name('b = ');
  // gui_b.onChange( function(value) { createGraph(); } );
  // gui_c = gui_parameters.add( this, 'c' ).min(-5).max(5).step(0.01).name('c = ');
  // gui_c.onChange( function(value) { createGraph(); } );
  // gui_d = gui_parameters.add( this, 'd' ).min(-5).max(5).step(0.01).name('d = ');
  // gui_d.onChange( function(value) { createGraph(); } );
  // gui_a.setValue(1);
  // gui_b.setValue(1);
  // gui_c.setValue(1);
  // gui_d.setValue(1);
  //
  // // GUI -- preset equations
  // var gui_preset = gui.addFolder('Preset equations');
  // gui_preset.add( parameters, 'preset1' ).name('Sine Circles');
  //
  // gui.add( parameters, 'resetCam' ).name("Reset Camera");
  // gui.add( parameters, 'graphFunc' ).name("Graph Function");
  //
  preset01();
}

Vector3 meshFunction(num x, num y, [dynamic other]) {
  x = xRange * x + xMin;
  y = yRange * y + yMin;
  var z = zFunc(x, y);
  if (z.isNaN)
    return new Vector3(0, 0, 0);
  else
    return new Vector3(x, y, z);
}

void createGraph() {
  xRange = xMax - xMin;
  yRange = yMax - yMin;
  // zFunc = Parser.parse(zFuncText).toJSFunction( ['x','y'] );

  // true => sensible image tile repeat...
  var graphGeometry =
      new ParametricGeometry(allowInterop(meshFunction), segments, segments);

  ///////////////////////////////////////////////
  // calculate vertex colors based on Z values //
  ///////////////////////////////////////////////
  graphGeometry.computeBoundingBox();
  zMin = graphGeometry.boundingBox.min.z;
  zMax = graphGeometry.boundingBox.max.z;
  zRange = zMax - zMin;
  // first, assign colors to vertices as desired
  graphGeometry.colors.length = graphGeometry.vertices.length;
  for (var i = 0; i < graphGeometry.vertices.length; i++) {
    var point = graphGeometry.vertices[i];
    var color = new Color(0x0000ff);
    color.setHSL(0.7 * (zMax - point.z) / zRange, 1, 0.5);
    graphGeometry.colors[i] = color; // use this array for convenience
  }
  // copy the colors as necessary to the face's vertexColors array.
  for (var i = 0; i < graphGeometry.faces.length; i++) {
    var face = graphGeometry.faces[i];
    face.vertexColors =
          [face.a, face.b, face.c].map((i) => graphGeometry.colors[i]).toList();
    // numberOfSides = (face is Face3) ? 3 : 4;
    // face.vertexColors = new List<Color>(numberOfSides);
    // face.vertexColors[0] = graphGeometry.colors[face.a];
    // face.vertexColors[1] = graphGeometry.colors[face.b];
    // face.vertexColors[2] = graphGeometry.colors[face.c];
    // if (face is! Face3) {
    //   face.vertexColors[3] = graphGeometry.colors[face.d];
    // }
    // for (var j = 0; j < numberOfSides; j++) {
    //   var faceIndex = faceIndices[j];
    //   switch (faceIndex) {
    //     case 'a':
    //       vertexIndex = face.a;
    //       break;
    //     case 'b':
    //       vertexIndex = face.b;
    //       break;
    //     case 'c':
    //       vertexIndex = face.c;
    //       break;
    //     case 'd':
    //       vertexIndex = face.d;
    //       break;
    //   }
    //   face.vertexColors[j] = graphGeometry.colors[vertexIndex];
    // }
  }
  ///////////////////////
  // end vertex colors //
  ///////////////////////

  // material choices: vertexColorMaterial, wireMaterial , normMaterial , shadeMaterial

  if (graphMesh != null) {
    scene.remove(graphMesh);
  }

  wireMaterial.map.repeat.set(segments, segments);
  wireMaterial.side = DoubleSide;
  graphMesh = new Mesh(graphGeometry, wireMaterial);

  scene.add(graphMesh);
  camera.position.set(2 * xMax, 0.5 * yMax, 4 * zMax);
}

void preset01() {
  // gui_zText.setValue("sin(sqrt(a*x^2  + b*y^2))");
  // gui_xMin.setValue(-10); gui_xMax.setValue(10);
  // gui_yMin.setValue(-10); gui_yMax.setValue(10);
  // gui_a.setValue(1);
  // gui_b.setValue(1);
  // gui_segments.setValue(40);
  createGraph();
  // resetCamera();
}

void resetCamera() {
  // CAMERA
  var SCREEN_WIDTH = window.innerWidth, SCREEN_HEIGHT = window.innerHeight;
  var VIEW_ANGLE = 45,
      ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT,
      NEAR = 0.1,
      FAR = 20000;
  camera = new PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
  camera.position.set(2 * xMax, 0.5 * yMax, 4 * zMax);
  camera.up = new Vector3(0, 0, 1);
  camera.lookAt(scene.position);
  scene.add(camera);

  controls = new TrackballControls(camera, renderer.domElement);
}

void animate(_) {
  window.requestAnimationFrame(animate);
  render();
  update();
}

void update() {
  // if ( keyboard.pressed("z") )
  // {
  // 	// do something
  // }
  controls.update();
  // stats.update();
}

void render() {
  renderer.render(scene, camera);
}
