#!/bin/bash
# Builds this checkout of MapLibre Native as an iOS XCFramework zip or an Android AAR.
#
#   TOOLS=<dir> ARTIFACTS=<dir> terrain-build/build.sh ios                 # the dynamic Metal XCFramework zip, optimised
#   TOOLS=<dir> ARTIFACTS=<dir> terrain-build/build.sh android <version>   # the openglRelease AAR for arm64-v8a, to a local Maven folder
#
# TOOLS holds bazelisk (bin/bazelisk), Bazel's caches and, for Android, a CMake 3.25 or newer home whose path is in
# cmake-home.txt. ARTIFACTS receives the outputs. ENGINE defaults to this checkout. Android also needs ANDROID_HOME,
# JAVA_HOME and, optionally, GRADLE_USER_HOME.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
TOOLS=${TOOLS:?set TOOLS to the build tools folder}
ARTIFACTS=${ARTIFACTS:?set ARTIFACTS to the output folder}
ENGINE=${ENGINE:-$(cd "$HERE/.." && pwd)}
export TMPDIR=$TOOLS/tmp
mkdir -p "$TMPDIR" "$ARTIFACTS"

case "${1:-}" in
  ios)
    export BAZELISK_HOME=$TOOLS/bazelisk-home
    cd "$ENGINE/platform/ios"
    # Drops the x86_64 simulator slice, a build configuration change, not an engine change. The XCFramework is then
    # Apple silicon only: an Intel Mac can't build or run an app for the simulator with it.
    git -C "$ENGINE" apply --check "$HERE/ios-drop-x86_64.patch" 2>/dev/null && git -C "$ENGINE" apply "$HERE/ios-drop-x86_64.patch"
    BAZEL=("$TOOLS/bin/bazelisk" "--output_user_root=$TOOLS/bazel-output-root")
    # The same flags as upstream's ios-release.yml for MapLibre.dynamic.
    FLAGS=(--compilation_mode=opt --//:renderer=metal --//:plugins=false --features=dead_strip,thin_lto
      --objc_enable_binary_stripping --apple_generate_dsym "--embed_label=maplibre_ios_$(cat VERSION)"
      "--repository_cache=$TOOLS/bazel-repository-cache" "--disk_cache=$TOOLS/bazel-disk-cache"
      --experimental_repository_downloader_retries=8)
    "${BAZEL[@]}" build "${FLAGS[@]}" //platform/ios:MapLibre.dynamic
    BIN=$("${BAZEL[@]}" info "${FLAGS[@]}" bazel-bin)
    mkdir -p "$ARTIFACTS/ios-build"
    cp -f "$BIN/platform/ios/MapLibre.dynamic.xcframework.zip" "$ARTIFACTS/ios-build/"
    shasum -a 256 "$ARTIFACTS/ios-build/MapLibre.dynamic.xcframework.zip"
    ;;
  android)
    VERSION=${2:?a version, such as 13.7.1-terrain.1}
    : "${ANDROID_HOME:?set ANDROID_HOME}" "${JAVA_HOME:?set JAVA_HOME}"
    # As upstream's android-release.yml does before it builds.
    (cd "$ENGINE" && npm install --ignore-scripts --cache "$TOOLS/npm-cache" --no-audit --no-fund)
    cd "$ENGINE/platform/android"
    # Gradle takes CMake and Ninja from cmake.dir: the engine needs CMake 3.25 or newer.
    printf 'sdk.dir=%s\ncmake.dir=%s\n' "$ANDROID_HOME" "$(cat "$TOOLS/cmake-home.txt")" > local.properties
    printf '%s\n' "$VERSION" > VERSION
    ./gradlew --no-daemon -Pmaplibre.abis=arm64-v8a "-PpublicationRepositoryUrl=file://$ARTIFACTS/maven" \
      :MapLibreAndroid:publishOpenglReleasePublications
    find "$ARTIFACTS/maven" -name "*-$VERSION.aar" -exec shasum -a 256 {} +
    ;;
  *)
    echo "usage: $0 ios | android <version>" >&2
    exit 2
    ;;
esac
