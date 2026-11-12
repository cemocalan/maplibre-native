# Terrain 3D build

This branch, `terrain-3d-build-2`, builds MapLibre Native for 3D terrain: upstream's `feature/terrain-3d` at
`7f6f88de41682e80025e1df5d75ba2bcbcb23c2b`, unchanged, plus this folder. No engine source patches are carried.
The build script and the patch are carried over unchanged from `terrain-3d-build`, which builds the earlier engine
commit `19e3604697256a7a78638f732834774c58e62325`.

- `build.sh` builds the iOS XCFramework zip and the Android AAR.
- `ios-drop-x86_64.patch` is its one build change: it drops the iOS simulator's x86_64 slice. The iOS build is
  therefore Apple silicon only; an Intel Mac can't build or run a simulator app with it.

Built artifacts are published from this fork, never re-uploaded under the same name:

- iOS: a release per version, tagged `ios-<version>`, consumed through the Swift package
  `cemocalan/maplibre-terrain-spm`.
- Android: a static Maven layout on the `maven` branch, served from
  `https://raw.githubusercontent.com/cemocalan/maplibre-native/maven/`.
