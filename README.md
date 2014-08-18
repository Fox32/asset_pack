# asset_pack #
==============

[![Build Status](https://drone.io/github.com/johnmccutchan/asset_pack/status.png)](https://drone.io/github.com/johnmccutchan/asset_pack/latest)

## Introduction ##

An asset management library for Dart games. Assets are organized into a tree
of asset packs. Assets can be any resource from a simple text string to a
complex skinned character.

Typically an asset pack file is loaded from the network, parsed, and all child
assets are loaded from the network and imported. An asset pack file is a JSON
text file describing the child assets. Asset packs and assets can also be
programmatically added.

`asset_pack` is designed to be extended by third party libraries which provide
their own loaders and importers.

## Overview ##

Each asset manager has a tree of asset packs. Each asset pack contains
assets and other asset packs. Every asset has a logical asset path, which
is a `.` separated list of strings. Example asset paths follow:

* animals.cats.pic
* animals.kinds
* animals.dogs.pic

## Why asset_pack ? ##

The `asset_pack` library makes runtime loading of game assets a breeze. Also,
the library has friendly developer tools for creating pack files and
deep integration with other game libraries for Dart.

## Features ##

* Powerful runtime asset importing.
* Friendly developer tools for building, editing, and listing `.pack` files.
* API for adding assets programmatically.
* Integration with third party libraries including `spectre` and `simple_audio`.

## How are assets accessed ? ##

Imported assets are accessed via the [] operator. The root of the tree is
accessed via the `root` property on an `AssetManager`. Example:

`ImageElement image = assetManager.root['animals.cats.picture'];`

Each imported asset also has an associated `Asset` instance. An `Asset` holds
metadata associated with the imported asset. It can be accessed via the
`assets` map of the `AssetPack` or `getAssetAtPath`. Example:

`Asset asset = assetManager.getAssetAtPath('animals.cats.picture');`

## How are assets loaded? ##

Assets are loaded by loading an asset pack. Each asset listed in an asset pack
is loaded via an `AssetLoader` and then imported by an `AssetImporter`.

## Which loaders and importers come out of the box? ##

Loaders:
* ArrayBufferLoader
* BlobLoader
* ImageLoader
* TextLoader
* TextMapLoader

Importers:
* JsonImporter
* PackImporter
* TextImporter

## I want to add an importer for a new asset type, what do I do? ##

Implement an `AssetImporter` and add it to the the `importers` map of the
`AssetManager`.

## I want to add a loader for a new asset type, what do I do? ##

Implement an `AssetLoader` and add it to the the `loaders` map of the
`AssetManager`.

*NOTE:* In many cases it's unnecessary to write a new loader.

## Getting Started ##

1\. Add the following to your project's **pubspec.yaml** and run ```pub install```.

```yaml
dependencies:
  asset_pack:
    git: https://github.com/johnmccutchan/asset_pack.git
```

2\. Add the correct import for your project. If you are writing a browser
package use:

```dart
import 'package:asset_pack/asset_pack_browser.dart';
```

# Documentation #

## Key Classes ##

* `AssetPack` A set of assets which are loaded and unloaded atomically. May
reference other asset packs.
* `Asset` The meta-data for an asset which has been loaded and imported.
* `AssetManager` Holds the root of the asset tree.
* `AssetLoader` A class which loads data from a URL.
* `AssetImporter` A class which imports data loaded from an `AssetLoader`.

## API ##

[Reference Manual](http://www.dartdocs.org/documentation/asset_pack/latest/index.html#asset_pack)

## Samples ##

## Examples ##

1\. Initialize an AssetManager:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManagerBrowser();
}
```

2\. Load a pack:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManagerBrowser();
  // Load 'explosions' from 'explosions.pack'.
  AssetPack explosions = assets.load('explosions', 'domain/explosions.pack');
}
```

3\. Access a loaded asset:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManagerBrowser();
  // Load 'explosions' from 'explosions.pack'.
  AssetPack explosions = assets.load('explosions', 'domain/explosions.pack');
  // Explosions has a 'dynamite' asset which is a sound clip.
  playSound(assets['explosions.dynamite']);
}
```

4\. Programmatically add an asset pack:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManagerBrowser();
  // Register the 'test' pack. No url is needed so the empty string suffices.
  AssetPack testPack = assets.registerPack('test', '');
  // testPack and ['test'] are both the same object.
  assert(assets['test'] == testPack);
  Asset testPackAsset = assets.getAssetAtPath('test');
  // The imported field of testPackAsset is testPack.
  assert(testPackAsset.imported == testPack);
}
```

5\. Programmatically load and register an asset:

```dart
main() {
  // Construct a new AssetManager.
  AssetManager assets = new AssetManagerBrowser();
  // Register the 'test' pack. No url is needed so the empty string suffices.
  AssetPack testPack = assets.registerPack('test', '');
  // Register asset 'foo' and load it's contents from 'foo.txt'.
  // The asset type is 'text' and there are no arguments for the loader
  // or importer.
  Future<Asset> futureAsset = testPack.loadAndRegisterAsset('foo', 'foo.txt',
                                                            'text', {}, {})
  futureAsset.then((asset) {
    // Print the contents of foo.txt.
    print(asset.imported);
  });
}
```