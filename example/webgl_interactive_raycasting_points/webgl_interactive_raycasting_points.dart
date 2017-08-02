import 'dart:html';
import 'dart:typed_data';
import 'dart:math';
import 'package:threejs_facade/three.dart';

Renderer renderer;
Scene scene;
PerspectiveCamera camera;

var pointclouds;
Raycaster raycaster;
var mouse = new Vector2();
var intersection = null;
var spheres = [];
var spheresIndex = 0;
var clock;

var threshold = 0.1;
var pointSize = 0.05;
var width = 150;
var length = 150;
var rotateY = new Matrix4().makeRotationY(0.005);

void main() {
  init();
  animate(null);
}

BufferGeometry generatePointCloudGeometry(color, width, length) {
  var geometry = new BufferGeometry();
  var numPoints = width * length;

  var positions = new Float32List(numPoints * 3);
  var colors = new Float32List(numPoints * 3);

  var k = 0;

  for (var i = 0; i < width; i++) {
    for (var j = 0; j < length; j++) {
      var u = i / width;
      var v = j / length;
      var x = u - 0.5;
      var y = (cos(u * PI * 8) + sin(v * PI * 8)) / 20;
      var z = v - 0.5;

      positions[3 * k] = x;
      positions[3 * k + 1] = y;
      positions[3 * k + 2] = z;

      var intensity = (y + 0.1) * 5;
      colors[3 * k] = color.r * intensity;
      colors[3 * k + 1] = color.g * intensity;
      colors[3 * k + 2] = color.b * intensity;

      k++;
    }
  }

  geometry.addAttribute('position', new BufferAttribute(positions, 3));
  geometry.addAttribute('color', new BufferAttribute(colors, 3));
  geometry.computeBoundingBox();

  return geometry;
}

Points generatePointcloud(color, width, length) {
  var geometry = generatePointCloudGeometry(color, width, length);
  var material = new PointsMaterial(new PointsMaterialParameters()
    ..size = pointSize
    ..vertexColors = VertexColors);
  var pointcloud = new Points(geometry, material);
  return pointcloud;
}

Points generateIndexedPointcloud(color, width, length) {
  var geometry = generatePointCloudGeometry(color, width, length);
  var numPoints = width * length;
  var indices = new Uint16List(numPoints);

  var k = 0;

  for (var i = 0; i < width; i++) {
    for (var j = 0; j < length; j++) {
      indices[k] = k;
      k++;
    }
  }

  geometry.setIndex(new BufferAttribute(indices, 1));

  var material = new PointsMaterial(new PointsMaterialParameters()
    ..size = pointSize
    ..vertexColors = VertexColors);
  var pointcloud = new Points(geometry, material);
  return pointcloud;
}

Points generateIndexedWithOffsetPointcloud(color, width, length) {
  var geometry = generatePointCloudGeometry(color, width, length);
  var numPoints = width * length;
  var indices = new Uint16List(numPoints);

  var k = 0;

  for (var i = 0; i < width; i++) {
    for (var j = 0; j < length; j++) {
      indices[k] = k;
      k++;
    }
  }

  geometry.setIndex(new BufferAttribute(indices, 1));
  geometry.addGroup(0, indices.length);

  var material = new PointsMaterial(new PointsMaterialParameters()
    ..size = pointSize
    ..vertexColors = VertexColors);
  var pointcloud = new Points(geometry, material);

  return pointcloud;
}

Points generateRegularPointcloud(color, width, length) {
  var geometry = new Geometry();
  var colors = [];
  for (var i = 0; i < width; i++) {
    for (var j = 0; j < length; j++) {
      var u = i / width;
      var v = j / length;
      var x = u - 0.5;
      var y = (cos(u * PI * 8) + sin(v * PI * 8)) / 20;
      var z = v - 0.5;
      var vec = new Vector3(x, y, z);
      geometry.vertices.add(vec);
      var intensity = (y + 0.1) * 7;
      colors.add(color.clone().multiplyScalar(intensity));
    }
  }

  geometry.colors = colors;
  geometry.computeBoundingBox();

  var material = new PointsMaterial(new PointsMaterialParameters()
    ..size = pointSize
    ..vertexColors = VertexColors);
  var pointcloud = new Points(geometry, material);
  return pointcloud;
}

void init() {
  var container = querySelector('#container');

  scene = new Scene();
  clock = new Clock();

  camera = new PerspectiveCamera(
      45, window.innerWidth / window.innerHeight, 1, 10000);
  camera.applyMatrix(new Matrix4().makeTranslation(0, 0, 20));
  camera.applyMatrix(new Matrix4().makeRotationX(-0.5));

  var pcBuffer = generatePointcloud(new Color(1, 0, 0), width, length);
  pcBuffer.scale.set(10, 10, 10);
  pcBuffer.position.set(-5, 0, 5);
  scene.add(pcBuffer);

  var pcIndexed = generateIndexedPointcloud(new Color(0, 1, 0), width, length);
  pcIndexed.scale.set(10, 10, 10);
  pcIndexed.position.set(5, 0, 5);
  scene.add(pcIndexed);

  var pcIndexedOffset =
      generateIndexedWithOffsetPointcloud(new Color(0, 1, 1), width, length);
  pcIndexedOffset.scale.set(10, 10, 10);
  pcIndexedOffset.position.set(5, 0, -5);
  scene.add(pcIndexedOffset);

  var pcRegular = generateRegularPointcloud(new Color(1, 0, 1), width, length);
  pcRegular.scale.set(10, 10, 10);
  pcRegular.position.set(-5, 0, -5);
  scene.add(pcRegular);

  pointclouds = [pcBuffer, pcIndexed, pcIndexedOffset, pcRegular];

  //

  var sphereGeometry = new SphereGeometry(0.1, 32, 32);
  var sphereMaterial = new MeshBasicMaterial(new MeshBasicMaterialParameters()
    ..color = 0xff0000
    ..shading = FlatShading);

  for (var i = 0; i < 40; i++) {
    var sphere = new Mesh(sphereGeometry, sphereMaterial);
    scene.add(sphere);
    spheres.add(sphere);
  }

  renderer = new WebGLRenderer();
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  container.append(renderer.domElement);

  raycaster = new Raycaster();
  raycaster.params.Points.threshold = threshold;

  // stats = new Stats();
  // container.appendChild( stats.dom );

  window.onResize.listen(onWindowResize);
  document.onMouseMove.listen(onDocumentMouseMove);
}

void onDocumentMouseMove(MouseEvent event) {
  event.preventDefault();
  mouse.x = (event.client.x / window.innerWidth) * 2 - 1;
  mouse.y = -(event.client.y / window.innerHeight) * 2 + 1;
}

void onWindowResize(Event _) {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  renderer.setSize(window.innerWidth, window.innerHeight);
}

void animate(num _) {
  window.requestAnimationFrame(animate);
  render();
  // stats.update();
}

var toggle = 0;

void render() {
  camera.applyMatrix(rotateY);
  camera.updateMatrixWorld();
  raycaster.setFromCamera(mouse, camera);

  var intersections = raycaster.intersectObjects(pointclouds);
  intersection = intersections.isEmpty ? null : intersections[0];

  if (toggle > 0.02 && intersection != null) {
    spheres[spheresIndex].position.copy(intersection.point);
    spheres[spheresIndex].scale.set(1, 1, 1);
    spheresIndex = (spheresIndex + 1) % spheres.length;

    toggle = 0;
  }

  for (var i = 0; i < spheres.length; i++) {
    var sphere = spheres[i];
    sphere.scale.multiplyScalar(0.98);
    sphere.scale.clampScalar(0.01, 1);
  }

  toggle += clock.getDelta();

  renderer.render(scene, camera);
}
