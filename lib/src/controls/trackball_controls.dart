@JS('THREE')
library threejs.controls.trackball;

import 'dart:html';
import 'package:js/js.dart';
import 'package:threejs_facade/three.dart';

@JS()
class TrackballControls {
  external factory TrackballControls(Camera camera, Element domElement);
  external Element get domElement;
  external void set domElement(Element domElement);

  external num get rotateSpeed;
  external void set rotateSpeed(num rotateSpeed);

  external num get zoomSpeed;
  external void set zoomSpeed(num zoomSpeed);

  external num get panSpeed;
  external void set panSpeed(num panSpeed);

  external bool get noRotate;
  external void set noRotate(bool noRotate);

  external bool get noZoom;
  external void set noZoom(bool noZoom);

  external bool get noPan;
  external void set noPan(bool noPan);

  external bool get staticMoving;
  external void set staticMoving(bool staticMoving);

  external num get minDistance;
  external void set minDistance(num minDistance);

  external num get maxDistance;
  external void set maxDistance(num maxDistance);

  external List<int> get keys;
  external void set keys(List<int> keys);

  external void update();
}
