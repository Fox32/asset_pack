/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'package:asset_pack/asset_pack_browser.dart';

main() {
  demoWithTestAssets();
  demoWithFakeAssets();
}

demoWithTestAssets() {
  var bar = querySelector("#assetProgressTestAssets");
  var log = querySelector("#assetLogTestAssets");
  var tracer = new AssetPackTrace();

  var stream = tracer.asStream().asBroadcastStream();
  new ProgressControler(bar).bind(stream);
  new EventsPrintControler(log).bind(stream);

  AssetManager assetManager = new AssetManagerBrowser(tracer);
  assetManager.loadPack('testpack', 'testpack.pack');
  assetManager.loadPack('testpack2', 'testpackbadname.pack');
  assetManager.loadPack('brokenpack', 'brokenpack.pack');
}

demoWithFakeAssets() {
  var bar = querySelector("#assetProgressFakeAssets");
  var barW = querySelector("#assetProgressFakeAssetsOld");
  var log = querySelector("#assetLogFakeAssets");
  var tracer = new AssetPackTrace();

  var stream = tracer.asStream().asBroadcastStream();
  new ProgressControler(bar).bind(stream);
  new ProgressControler(barW).bind(stream);
  new EventsPrintControler(log).bind(stream);

  var d1s = new Duration(seconds: 1);
  var d2s = new Duration(seconds: 2);
  AssetManager assetManager = new AssetManagerBrowser(tracer);
  assetManager.loaders['fake'] = new FakeLoaderWait(d2s);
  assetManager.importers['fake'] = new FakeImporterWait(d1s);
  var random = new Random();
  for(var i = 0; i < 5; i++) {
    var delay = random.nextInt(5000);
    new Timer(new Duration(milliseconds: delay), (){
      assetManager.loadAndRegisterAsset(
        'fake${i}', 'fake', '/f${i}', null, null
      );
    });
  }
}

class FakeLoaderWait extends AssetLoader {
  final Duration delay;

  FakeLoaderWait(this.delay);

  Future<Asset> load(Asset asset, AssetPackTrace tracer) {
    tracer.assetLoadStart(asset);
    try {
      var c = new Completer();
      new Timer(delay, () => c.complete(asset));
      return c.future;
    } finally {
      tracer.assetLoadEnd(asset);
    }
  }

  void delete(dynamic imported) {
  }
}

class FakeImporterWait extends AssetImporter {
  final Duration delay;

  FakeImporterWait(this.delay);

  void initialize(Asset asset) {
    asset.imported = '';
  }
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {
    tracer.assetImportStart(asset);
    try {
      var c = new Completer();
      new Timer(new Duration(seconds: 1), () => c.complete(asset));
      return c.future;
    } finally {
      tracer.assetImportEnd(asset);
    }
  }

  void delete(dynamic imported) {
  }
}


class EventsPrintControler {
  final Element _view;

  EventsPrintControler(this._view);

  StreamSubscription bind(Stream<AssetPackTraceEvent> tracer) {
    return tracer.listen(onEvent);
  }

  void onEvent(AssetPackTraceEvent event) {
    _view.text = _view.text + event.toString() + '\n';
  }
}