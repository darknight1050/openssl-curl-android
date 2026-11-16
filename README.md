# libcurl for Quest

QPM v2 shared package bundling curl, OpenSSL, zlib, Brotli, zstd, nghttp2, nghttp3, and ngtcp2.
Supports IPv6, HTTP/2, HTTP/3, threaded DNS, and proxies.
Only curl's public API is exported; bundled backends remain private.

Targets **ARM64, Android API 27** (including Android 10), built with **NDK r29**.
Package version: **8.23.0**.

| Library | Version |
| --- | --- |
| curl | 8.23.0 |
| OpenSSL | 4.1.0 |
| zlib | 1.4 |
| Brotli | 1.2.1 |
| zstd | 1.5.7 |
| nghttp2 | 1.71.0 |
| nghttp3 | 1.19.0 |
| ngtcp2 | 1.26.0 |

## Build

Use Linux/WSL with QPM v2, Git, Python 3, Perl, Make, CMake, Autoconf, Automake,
Libtool, pkg-config, and a C/C++ toolchain installed. Commands below use `qpm2`.

```bash
git submodule update --init --depth 1
git -C nghttp3 submodule update --init --depth 1 lib/sfparse
qpm2 ndk resolve -d
qpm2 restore
qpm2 build
bash scripts/package.sh
```

Scripts are in `scripts/`. `dist/` contains the QPKG, QMOD, stripped `libcurl.so`,
matching `libcurl-debug.so` with DWARF symbols, build ID, build metadata, and SHA256 checksums.

## Use

Add to `qpm2.json`, then run `qpm2 restore`:

```json
"dependencies": {
  "libcurl": { "versionRange": "^8.23.0", "qmod": "required" }
}
```

For an unpublished local build, first run `qpm2 install --path path/to/libcurl-8.23.0.qpkg`.
Include `<libcurl/curl.h>` or `<curl/curl.h>` and link `extern/libs/libcurl.so`.
Rebuild consumers and generate their QMODs with QPM to include the required dependency.
Install `libcurl.qmod` once: it places `libcurl.so` in Scotland2's `libs`.
Consumers must not embed another copy in their QMODs.

## CI

Pushes and PRs build all artifacts. A `v<version>` tag publishes them to a GitHub
release and registers the shared QPKG using the **QPM_KEY** secret.
Update both `version` and `qmod.downloadUrl` in `qpm2.json` before tagging.
