import 'dart:html';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:js';
import 'package:threejs_facade/three.dart';

// if ( ! Detector.webgl ) Detector.addGetWebGLMessage();
DivElement container;
// var stats;

PerspectiveCamera camera;
Scene scene;
WebGLRenderer renderer;
Mesh mesh;
DateTime startTime;
final random = new math.Random();

void init() {
  container = querySelector('#container');

  //

  camera = new PerspectiveCamera(
      27, window.innerWidth / window.innerHeight, 1, 3500);
  camera.position.z = 2750;

  scene = new Scene();
  scene.fog = new Fog(0x050505, 2000, 3500);

  //

  scene.add(new AmbientLight(new Color(0x444444)));

  var light1 = new DirectionalLight(new Color(0xffffff), 0.5);
  light1.position.set(1, 1, 1);
  scene.add(light1);

  var light2 = new DirectionalLight(new Color(0xffffff), 1.5);
  light2.position.set(0, -1, 0);
  scene.add(light2);

  //

  var triangles = 160000;

  var geometry = new BufferGeometry();

  var positions = new Float32List(triangles * 3 * 3);
  var normals = new Float32List(triangles * 3 * 3);
  var colors = new Float32List(triangles * 3 * 3);

  var color = new Color();

  var n = 800, n2 = n / 2; // triangles spread in the cube
  var d = 12, d2 = d / 2; // individual triangle size

  var pA = new Vector3();
  var pB = new Vector3();
  var pC = new Vector3();

  var cb = new Vector3();
  var ab = new Vector3();

  for (var i = 0; i < positions.length; i += 9) {
    // positions

    var x = random.nextDouble() * n - n2;
    var y = random.nextDouble() * n - n2;
    var z = random.nextDouble() * n - n2;

    var ax = x + random.nextDouble() * d - d2;
    var ay = y + random.nextDouble() * d - d2;
    var az = z + random.nextDouble() * d - d2;

    var bx = x + random.nextDouble() * d - d2;
    var by = y + random.nextDouble() * d - d2;
    var bz = z + random.nextDouble() * d - d2;

    var cx = x + random.nextDouble() * d - d2;
    var cy = y + random.nextDouble() * d - d2;
    var cz = z + random.nextDouble() * d - d2;

    positions[i] = ax;
    positions[i + 1] = ay;
    positions[i + 2] = az;

    positions[i + 3] = bx;
    positions[i + 4] = by;
    positions[i + 5] = bz;

    positions[i + 6] = cx;
    positions[i + 7] = cy;
    positions[i + 8] = cz;

    // flat face normals

    pA.set(ax, ay, az);
    pB.set(bx, by, bz);
    pC.set(cx, cy, cz);

    cb.subVectors(pC, pB);
    ab.subVectors(pA, pB);
    cb.cross(ab);

    cb.normalize();

    var nx = cb.x;
    var ny = cb.y;
    var nz = cb.z;

    normals[i] = nx;
    normals[i + 1] = ny;
    normals[i + 2] = nz;

    normals[i + 3] = nx;
    normals[i + 4] = ny;
    normals[i + 5] = nz;

    normals[i + 6] = nx;
    normals[i + 7] = ny;
    normals[i + 8] = nz;

    // colors

    var vx = (x / n) + 0.5;
    var vy = (y / n) + 0.5;
    var vz = (z / n) + 0.5;

    color.setRGB(vx, vy, vz);

    colors[i] = color.r;
    colors[i + 1] = color.g;
    colors[i + 2] = color.b;

    colors[i + 3] = color.r;
    colors[i + 4] = color.g;
    colors[i + 5] = color.b;

    colors[i + 6] = color.r;
    colors[i + 7] = color.g;
    colors[i + 8] = color.b;
  }

  // void disposeArray() { this.array = null; }
  Function disposeArrayFn(BufferAttribute attr) {
    return allowInterop(() => attr.array = null);
  }

  var positionAttr = new BufferAttribute(positions, 3);
  var normalAttr = new BufferAttribute(normals, 3);
  var colorAttr = new BufferAttribute(colors, 3);

  geometry.addAttribute(
      'position', positionAttr.onUpload(disposeArrayFn(positionAttr)));
  geometry.addAttribute(
      'normal', normalAttr.onUpload(disposeArrayFn(normalAttr)));
  geometry.addAttribute('color', colorAttr.onUpload(disposeArrayFn(colorAttr)));

  geometry.computeBoundingSphere();

  // var params = new MeshPhongMaterialParameters()
  //   ..color = new Color(0xaaaaaa)
  //   ..specular = 0xffffff
  //   ..shininess = 250
  //   ..side = DoubleSide
  //   ..vertexColors = VertexColors;
  // var material = new MeshPhongMaterial(params);
  var material = new MeshPhongMaterial()
    ..color = new Color(0xaaaaaa)
    ..specular = new Color(0xffffff)
    ..shininess = 250
    ..side = DoubleSide
    ..vertexColors = VertexColors;

  mesh = new Mesh(geometry, material);
  scene.add(mesh);

  renderer = new WebGLRenderer();
  // ..antialias = false;
  renderer.setClearColor(scene.fog.color);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);

  renderer.gammaInput = true;
  renderer.gammaOutput = true;

  container.append(renderer.domElement);

  //

  // stats = new Stats();
  // container.appendChild( stats.dom );

  //
  window.onResize.listen(onWindowResize);
  startTime = new DateTime.now();
}

void onWindowResize(_) {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

//

void animate(_) {
  window.requestAnimationFrame(animate);
  render();
  // stats.update();
}

void render() {
  var time = new DateTime.now().difference(startTime).inMilliseconds / 1000;
  mesh.rotation.x = time * 0.25;
  mesh.rotation.y = time * 0.5;
  renderer.render(scene, camera);
}

void main() {
  init();
  animate(null);
}
