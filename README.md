# Maven repository for MapLibre Native with 3D terrain

A static Maven layout, served from `https://raw.githubusercontent.com/cemocalan/maplibre-native/maven/`. It holds
Android builds of MapLibre Native (`org.maplibre.gl:android-sdk-opengl`, arm64-v8a, openglRelease), made with
`terrain-build/build.sh`: `13.7.1-terrain.1` from the `terrain-3d-build` branch, `13.7.1-terrain.2` from
`terrain-3d-build-2`. Every build has a new version; a published version is never
replaced. Each file sits beside its MD5, SHA-1, SHA-256 and SHA-512, as Gradle publishes them; Gradle uses those for
caching, not to verify a download, so a consumer should pin the AAR's SHA-256 itself.
