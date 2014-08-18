import 'dart:io';
import 'dart:convert';
import 'package:asset_pack/asset_pack_standalone.dart';

AssetPackFile openAssetPackFile(String path) {
  var out = FileSystemEntity.isDirectorySync(path)
      ? new File('$path/_.pack')
      : new File(path)
      ;
  String contents;
  try {
    contents = out.readAsStringSync();
  } catch (_) {
    print('Could not open existing asset pack file: ${out.path}');
    print('Creating new assset pack.');
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  var json;
  try {
    json = JSON.decode(contents);
  } catch (e) {
    print(e);
    print('Could not parse existing asset pack file: ${out.path}');
    print('Creating new assset pack.');
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  print('Loaded existing asset pack file: ${out.path}');
  return new AssetPackFile.fromJson(json);
}

main(List<String> arguments) {
  bool verbose = true;
  String inPath;
  if (arguments.length == 0) {
    inPath = '${Directory.current.path}/test/testpack';
  } else {
    inPath = arguments[0];
  }
  AssetPackFile packFile = openAssetPackFile(inPath);
  var assets = packFile.assets.values.toList();
  assets.sort((a, b) => Comparable.compare(a.name, b.name));
  assets.sort((a, b) => Comparable.compare(a.type, b.type));
  int count = 0;
  assets.forEach((f) {
    var name = f.name;
    var url = f.url;
    var type = f.type;
    print('$count $name $type ($url)');
    if (verbose) {
      print('$count   L: ${f.loadArguments}');
      print('$count   I: ${f.importArguments}');
    }
    count++;
  });
}