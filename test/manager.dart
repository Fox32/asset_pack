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

part of asset_pack_tests;

class Manager {
  static void loadTest() {
    AssetManager assetManager = new AssetManagerBrowser();
    Future<AssetPack> futurePack;
    test('success.', () {
      futurePack = assetManager.loadPack('testpack', 'testpack/_.pack');
      futurePack.then(expectAsync((pack) {
        expect(pack == null, false);
        expect(pack.length, 5);
        expect(pack['subpack'].length, 1);
        expect(assetManager['testpack.subpack'].length, 1);
        expect(assetManager['testpack.subpack.somemap'].containsKey('a'), true);
        expect(assetManager['testpack.subpack.somemap']['a'], 'b');
        expect(assetManager['testpack.subpack'].parent,
               assetManager['testpack']);
        expect(pack['subpack'].type('somemap'), 'json');
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'], pack);
        expect(assetManager.getAssetAtPath('testpack').imported, pack);
        expect(() {
          assetManager.getAssetAtPath('testpack.');
        }, throws);
        expect(() {
          assetManager.getAssetAtPath('.');
        }, throws);
        expect(() {
          assetManager.getAssetAtPath('');
        }, throws);
        expect(pack.type('list') , 'json');
        expect(pack.type('map')  , 'json');
        expect(pack.type('test') , 'json');
        expect(pack.type('tests'), 'text');
      }));
    });
    test('duplicate pack', () {
      expect(() => assetManager.loadPack('testpack', 'testpack/_.pack'),
                                         throws);
    });
    test('failure', () {
      futurePack = assetManager.loadPack('testpack2', 'testpackbadname.pack');
      futurePack.then(expectAsync((pack) {
        expect(pack.length, 0);
      }));
    });
    test('badpack', () {
      futurePack = assetManager.loadPack('brokenpack', 'brokenpack.pack');
      futurePack.then(expectAsync((pack) {
        expect(pack.length, 0);
      }));
    });
  }
  static void reloadTest() {
    AssetManager assetManager = new AssetManagerBrowser();
    Future<AssetPack> futurePack;
    test('sub pack', () {
      futurePack = assetManager.loadPack('testpack', 'testpack/_.pack');
      futurePack.then(expectAsync((pack) {
        // Test reload on sub pack as reloading nested packs is not supported
        // at the moment.
        var subpack = assetManager['testpack.subpack'];
        // Store the current map to check against after reload.
        var firstLoadMap = assetManager['testpack.subpack.somemap'];

        subpack.reload().then(expectAsync((_) {
          expect(assetManager['testpack.subpack'].length, 1);
          expect(assetManager['testpack.subpack.somemap'], isNot(same(firstLoadMap)));
          expect(assetManager['testpack.subpack.somemap'].containsKey('a'), true);
          expect(assetManager['testpack.subpack.somemap']['a'], 'b');
          expect(assetManager['testpack.subpack'].parent,
                 assetManager['testpack']);
          expect(pack['subpack'].type('somemap'), 'json');
          expect(assetManager.getAssetAtPath('testpack.subpack.somemap').status, equals('OK'));
        }));
      }));
    });
  }
  static void unloadTest() {
    test('unload', () {
      AssetPackTrace trace = new AssetPackTrace();
      AssetManager assetManager = new AssetManagerBrowser(trace);
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack/_.pack');
      futurePack.then(expectAsync((pack) {
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'] == null, false);
        expect(assetManager['testpack'].parent, assetManager.root);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(pack.parent, null);
        expect(assetManager.root.assets.length, 0);
        expect(pack.type('list') , null);
        expect(pack.type('map')  , null);
        expect(pack.type('test') , null);
        expect(pack.type('tests'), null);
        expect(() => assetManager.getAssetAtPath('testpack'), throws);
      }));
    });
    test('reload', () {
      AssetPackTrace trace = new AssetPackTrace();
      AssetManager assetManager = new AssetManagerBrowser(trace);
      Future<AssetPack> futurePack;
      futurePack = assetManager.loadPack('testpack', 'testpack/_.pack');
      futurePack.then(expectAsync((pack) {
        expect(assetManager.root.assets.length, 1);
        expect(assetManager['testpack'] == null, false);
        assetManager.deregisterPack('testpack');
        expect(pack.length, 0);
        expect(() => assetManager.getAssetAtPath('testpack'), throws);
        futurePack = assetManager.loadPack('testpack', 'testpack/_.pack');
        futurePack.then(expectAsync((pack) {
          //expect(pack.assets.length, 5);
          expect(assetManager.root.assets.length, 1);
          expect(assetManager['testpack'], pack);
          expect(pack.type('list') , 'json');
          expect(pack.type('map')  , 'json');
          expect(pack.type('test') , 'json');
          expect(pack.type('tests'), 'text');
          expect(assetManager['testpack'] == null, false);
          assetManager.deregisterPack('testpack');
          expect(() => assetManager.deregisterPack('testpack'), throws);
          expect(() => assetManager.getAssetAtPath('testpack'), throws);
        }));
      }));
    });
  }

  static void dynamicPackTest() {
    test('registerAsset', () {
      AssetPackTrace trace = new AssetPackTrace();
      AssetManager assetManager = new AssetManagerBrowser(trace);
      AssetPack pack = assetManager.root.registerPack('packy', '');
      expect(pack.parent, assetManager.root);
      Asset asset1 = pack.registerAsset('text', 'text', '', {}, {});
      expect(asset1.pack, pack);
      asset1.imported = 'hello'; // Set imported object.
      expect(() {
        // Second attempt to register asset 'packy.text' throws argument error.
        Asset asset2 = pack.registerAsset('text', 'text', '', {}, {});
      }, throws);
      // Asset can be accessed via assets map.
      Asset foundAsset = assetManager.getAssetAtPath('packy.text');
      expect(foundAsset, asset1);
      // Asset properly registered:
      expect(assetManager['packy.text'], 'hello');
      expect(asset1.importer, isNotNull);
      expect(asset1.loader, isNotNull);
      expect(asset1.status, 'OK');
      expect(asset1.type, 'text');
      expect(asset1.pack.type('text'), 'text');
      pack.deregisterAsset('text');
      assetManager.root.deregisterPack('packy');
      // Pack is removed.
      expect(() {
        // Access a non-existant asset throws.
        var i = assetManager.getAssetAtPath('packy');
      }, throws);
      expect(pack.parent, null);
      // Asset is not findable.
      expect(() {
        assetManager.getAssetAtPath('packy.text');
      }, throws);
    });
  }

  static void dynamicLoadTest() {
    test('loadAndRegisterAsset', () {
      AssetPackTrace trace = new AssetPackTrace();
      AssetManager assetManager = new AssetManagerBrowser(trace);
      Future load = assetManager.loadAndRegisterAsset(
          'test',
          'text',
          'testpack/json/test.json',
          {},
          {});

      load.then(expectAsync((asset) {
        // Test the asset itself
        expect(asset.pack, assetManager.root);
        expect(asset.status, 'OK');
        String expected = '{"a":[1,2,3]}';
        expect(asset.imported.startsWith(expected), true);
        expect(assetManager.root.assets.length, 1);
        expect(assetManager.root.length, 1);
        // Test the asset access through the assetManager
        expect(assetManager['test'].startsWith(expected), true);
        expect(assetManager.root.type('test'), 'text');
        // Deregister the asset
        assetManager.root.deregisterAsset('test');
        expect(() {
          // Access a non-existant asset throws.
          var i = assetManager.getAssetAtPath('test');
        }, throws);
        expect(assetManager.root.assets.length, 0);
        expect(assetManager.root.length, 0);
      }));
    });
  }

  static void textMapFromPack() {
    AssetPackTrace trace = new AssetPackTrace();
    AssetManager assetManager = new AssetManagerBrowser(trace);
    var futurePack = assetManager.loadPack('assets', 'text_map_pack/_.pack');
    futurePack.then(expectAsync((_) {
      expect(assetManager['assets'], _);
      expect(assetManager['assets'].length, 1);
      expect(assetManager['assets'].type('textmap'), 'textmap');
      expect(assetManager['assets.textmap'], isNotNull);
      expect(assetManager['assets.textmap']['foo'].startsWith("crab"), true);
      expect(assetManager['assets']['textmap']['bar'].startsWith("test"), true);
      expect(assetManager['assets']['textmap']['error'], isNull);
    }));
  }

  static void textMapFromAsset() {
    AssetPackTrace trace = new AssetPackTrace();
    AssetManager assetManager = new AssetManagerBrowser(trace);
    var futureAsset =
        assetManager.root.loadAndRegisterAsset('textmap', 'textmap',
                                               'text_map_pack/textmap.tmap',
                                               {}, {});
    futureAsset.then(expectAsync((asset) {
      Map textmap = asset.imported;
      expect(textmap['foo'], isNotNull);
      expect(textmap['foo'].startsWith("crab"), true);
      expect(textmap['bar'], isNotNull);
      expect(textmap['bar'].startsWith("test"), true);
      expect(textmap['error'], isNull);
    }));
  }

  static void imageMapFromPack() {
    AssetPackTrace trace = new AssetPackTrace();
    AssetManager assetManager = new AssetManagerBrowser(trace);
    var futurePack = assetManager.loadPack('assets', 'image_map_pack/_.pack');
    futurePack.then(expectAsync((_) {
      expect(assetManager['assets'], _);
      expect(assetManager['assets'].length, 1);
      expect(assetManager['assets'].type('imagemap'), 'imagemap');
      expect(assetManager['assets.imagemap'], isNotNull);
      expect(assetManager['assets.imagemap']['foo'], isNotNull);
      expect(assetManager['assets.imagemap']['foo'].width, 64);
      expect(assetManager['assets']['imagemap']['error'], isNull);
    }));
  }

  static void imagetMapFromAsset() {
    AssetPackTrace trace = new AssetPackTrace();
    AssetManager assetManager = new AssetManagerBrowser(trace);
    var futureAsset =
        assetManager.root.loadAndRegisterAsset('imagemap', 'imagemap',
                                               'image_map_pack/imagemap.imap',
                                               {}, {});
    futureAsset.then(expectAsync((asset) {
      Map imagemap = asset.imported;
      //expect(textmap['foo'], isNotNull);
      expect(imagemap['error'], isNull);
    }));
  }

  static void runTests() {
    group('loadPack', () {
      loadTest();
    });
    group('reloadPack', () {
      reloadTest();
    });
    group('unloadpack', () {
      unloadTest();
    });
    group('dynamicpack', () {
      dynamicPackTest();
      dynamicLoadTest();
    });
    group('textmap', () {
      test('textMapFromPack', textMapFromPack);
      test('textMapFromAsset', textMapFromAsset);
    });
    group('imagemap', () {
      test('imageMapFromPack', imageMapFromPack);
      test('imagetMapFromAsset', imagetMapFromAsset);
    });
  }
}
