# THREE.js Dart Interop Facade

# Disclaimer

Originally a Dart JS interop facade generated with [dts-converter](https://github.com/blockforest/dts-converter),
which takes TypeScript .d.ts definitions as input. [Source definition](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/cc3d223a946f661eff871787edeb0fcb8f0db156/threejs) taken from DefinitelyTyped.

While Dart Analyzer reports the resulting library as free of errors, nothing except what's needed by the demo has been tested.

The library will only be lightly maintained.

# Usage

Add a dependency in your `pubspec.yaml`

```yaml
dependencies:
  threejs_facade:
    git: https://github.com/jackd/threejs-dart-facade.git
```

Add the base javascript to your `.html` file.
```html
<!-- For dart 1.x -->
<script src="packages/threejs_facade/js/three.min.js"></script>
<script type="application/dart" src="foo.dart"></script>
<script src="packages/browser/dart.js"></script>
```

```html
<script src="packages/threejs_facade/js/three.min.js"></script>
<!-- For dart 2.x -->
<script defer src="foo.dart.js"></script>
```

If you use `TackballControls` from your dart script, also include the `Trackball.js` script
```html
<script src="packages/threejs_facade/js/controls/TrackballControls.js"></script>
```

# Example

Clone this repository and run `webdev/pub serve` (dart 1.x / 2.x respectively)
```bash
git clone https://github.com/jackd/threejs-dart-facade.git
cd threejs-dart-facade
pub get
pub serve example     # dart 1.x
webdev serve example  # dart 2.x
```
