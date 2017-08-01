@JS('THREE')
library threejs.CanvasRenderer;

import 'dart:html';
import "package:js/js.dart";

import "package:threejs_facade/three.dart";

@JS()
class CanvasRenderer extends Renderer {
  external factory CanvasRenderer();
  external setClearColor(Color color, [num alpha]);
  external setPixelRatio(double ratio);
  external CanvasElement get domElement;
  external set domElement(CanvasElement v);
  external render(Scene scene, Camera camera);
}
