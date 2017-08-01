import 'dart:html';
import 'dart:math' as math;
import 'package:threejs_facade/three.dart' as THREE;
import 'package:threejs_facade/renderers/canvas_renderer.dart';


THREE.OrthographicCamera camera;
THREE.Scene scene;
CanvasRenderer renderer;
DateTime startTime;

final container = new DivElement();
// var starts;
final random = new math.Random();

void init() {
  startTime = new DateTime.now();
  document.body.append(container);

  // var info = new DivElement();
  // info.style.position = 'absolute';
  // info.style.top = '10px';
  // info.style.width = '100%';
  // info.style.textAlign = 'center';
  // info.setInnerHtml('<a href="http://threejs.org" target="_blank">three.js</a> - orthographic view');
  // container.append( info );

  camera = new THREE.OrthographicCamera(
      window.innerWidth / -2,
      window.innerWidth / 2,
      window.innerHeight / 2,
      window.innerHeight / -2,
      -500,
      1000);
  camera.position.x = 200;
  camera.position.y = 100;
  camera.position.z = 200;

  scene = new THREE.Scene();

  // Grid

  var size = 500, step = 50;

  THREE.Geometry geometry;

  geometry = new THREE.Geometry();

  for (var i = -size; i <= size; i += step) {
    geometry.vertices.add(new THREE.Vector3(-size, 0, i));
    geometry.vertices.add(new THREE.Vector3(size, 0, i));

    geometry.vertices.add(new THREE.Vector3(i, 0, -size));
    geometry.vertices.add(new THREE.Vector3(i, 0, size));
  }

  // THREE.Material material;
  // material = new THREE.LineBasicMaterial(
  //   new THREE.LineBasicMaterialParameters()
  //     ..color = 0x000000
  //     ..opacity = 0.2);
  var basicMaterial = new THREE.LineBasicMaterial()
    ..color = new THREE.Color(0x000000)
    ..opacity = 0.2;

  var line = new THREE.LineSegments(geometry, basicMaterial);
  scene.add(line);

  // Cubes

  geometry = new THREE.BoxGeometry(50, 50, 50);
  var lambertMaterial = new THREE.MeshLambertMaterial()
    ..color = new THREE.Color(0xffffff)
    ..overdraw = 0.5;

  for (var i = 0; i < 100; i++) {
    var cube = new THREE.Mesh(geometry, lambertMaterial);

    cube.scale.y = (random.nextDouble() * 2 + 1).floor();

    cube.position.x =
        ((random.nextDouble() * 1000 - 500) / 50).floor() * 50 + 25;
    cube.position.y = (cube.scale.y * 50) / 2;
    cube.position.z =
        ((random.nextDouble() * 1000 - 500) / 50).floor() * 50 + 25;

    scene.add(cube);
  }

  // Lights
  var ambientLight = new THREE.AmbientLight(
    new THREE.Color((random.nextDouble() * 0x10).floor()));
      // new THREE.AmbientLight(random.nextDouble() * 0x10);
  scene.add(ambientLight);

  var l0 = new THREE.DirectionalLight(
      new THREE.Color((random.nextDouble() * 0xffffff).floor()));
  l0.position
    ..x = random.nextDouble() - 0.5
    ..y = random.nextDouble() - 0.5
    ..z = random.nextDouble() - 0.5
    ..normalize();
  scene.add(l0);

  var l1 = new THREE.DirectionalLight(
      new THREE.Color((random.nextDouble() * 0xffffff).floor()));
  l1.position
    ..x = random.nextDouble() - 0.5
    ..y = random.nextDouble() - 0.5
    ..z = random.nextDouble() - 0.5
    ..normalize();
  scene.add(l1);

  renderer = new CanvasRenderer();
  renderer.setClearColor(new THREE.Color(0xf0f0f0), 1);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  container.append(renderer.domElement);

  // stats = new Stats();
  // container.appendChild( stats.dom );

  //

  // window.addEventListener( 'resize', onWindowResize, false );
  window.onResize.listen(onWindowResize);
}

void onWindowResize(Event _) {
  camera.left = window.innerWidth / -2;
  camera.right = window.innerWidth / 2;
  camera.top = window.innerHeight / 2;
  camera.bottom = window.innerHeight / -2;

  camera.updateProjectionMatrix();

  renderer.setSize(window.innerWidth, window.innerHeight);
}

void animate(_) {
  window.requestAnimationFrame(animate);
  // stats.begin();
  render();
  // stats.end();
}

void render() {
  var t = new DateTime.now().difference(startTime).inMilliseconds / 10000;

  camera.position.x = math.cos(t) * 200;
  camera.position.z = math.sin(t) * 200;
  camera.lookAt(scene.position);

  renderer.render(scene, camera);
}

void main() {
  init();
  animate(null);
}
