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

part of asset_pack_standalone;

/// A [AssetLoader] for use in a standalone VM.
abstract class AssetLoaderStandalone extends AssetLoader {

  static Future<String> loadText(Asset asset, AssetPackTrace tracer) {
    tracer.assetLoadStart(asset);
    var completer = new Completer<String>();

    var file = new File(asset.url);

    file.readAsString().catchError((e, s) {
      tracer.assetLoadError(
          asset,
          "Error while loading : $e : $s"
      );

      tracer.assetLoadEnd(asset);

      completer.complete(null);
    }).then((t) {
      tracer.assetLoadEnd(asset);

      completer.complete(t);
    });

    return completer.future;
  }
}
