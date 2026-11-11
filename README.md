# Maven repository for MapLibre Native with 3D terrain

A static Maven layout, served from `https://raw.githubusercontent.com/cemocalan/maplibre-native/maven/`. It holds
Android builds of MapLibre Native from the `terrain-3d-build` branch (`org.maplibre.gl:android-sdk-opengl`, arm64-v8a,
openglRelease), made with `terrain-build/build.sh`. Every build has a new version; a published version is never
replaced. Each file sits beside its MD5, SHA-1, SHA-256 and SHA-512, as Gradle publishes them; Gradle uses those for
caching, not to verify a download, so a consumer should pin the AAR's SHA-256 itself.
