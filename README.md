# libsodium_dart_bindings

This project is tested with BrowserStack

[![Continous Integration for package sodium](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium)](https://pub.dev/packages/sodium)

[![Continous Integration for package sodium_libs](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml)
[![BrowserStack Status](https://app-automate.browserstack.com/badge.svg?badge_key=NGlSdXk1QkthUlNsWSs2MDBwNzdZeEFENzZUdTJJOENMai90MWxkVER1WT0tLTFUNzc3NkdvRjVRTUNDdGpHbjJ1RVE9PQ==--0232a0b87b5fe33e8bc322317d2be69648e48c57)](https://app-automate.browserstack.com/public-build/NGlSdXk1QkthUlNsWSs2MDBwNzdZeEFENzZUdTJJOENMai90MWxkVER1WT0tLTFUNzc3NkdvRjVRTUNDdGpHbjJ1RVE9PQ==--0232a0b87b5fe33e8bc322317d2be69648e48c57?redirect=true)
[![Pub Version](https://img.shields.io/pub/v/sodium_libs)](https://pub.dev/packages/sodium_libs)

This repository is a multi package repository for dart bindings of
[libsodium](https://libsodium.gitbook.io/doc/). It consists of the following
packages. Please check the READMEs of the specific packages for more details on
them.

If you just landed here and don't know where to start, simply read the
[sodium README](packages/sodium), as that is the primary package of this
repository.

- **[sodium](packages/sodium)**: Dart bindings for libsodium, supporting both
the VM and JS without flutter dependencies.
- **[sodium_libs](packages/sodium_libs)**: Flutter companion package to
[sodium](packages/sodium) that provides the low-level libsodium binaries for
easy use.
