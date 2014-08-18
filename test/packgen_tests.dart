import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';
import 'package:asset_pack/asset_pack_standalone.dart';

/// Signature for a packgen test.
typedef Future PackgenTest(int n);
typedef void PackgenTestStartup();

debug(s) {
  if (false) print(s);
}

//---------------------------------------------------------------------
// Test callback
//---------------------------------------------------------------------

Function finished;

/// Dummy callback to trick unittest.
void testComplete(name, n) {
  print('Test $n $name completed');
}

//---------------------------------------------------------------------
// Utility functions
//---------------------------------------------------------------------

/// Opens an [AssetPackFile] at the given [path].
AssetPackFile openAssetPackFile(String path) {
  File out = new File(path);
  String contents;
  try {
    contents = out.readAsStringSync();
  } catch (_) {
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  var json;
  try {
    json = JSON.decode(contents);
  } catch (e) {
    // Return empty asset pack file.
    return new AssetPackFile();
  }
  return new AssetPackFile.fromJson(json);
}

/// Copy the contents of a file to another file.
void copyFileContents(File original, File copy) {
  var input = original.openRead();
  var output = copy.openWrite();
  input.pipe(output).then((_) => output.close());
}

/// Copy the contents of the directory.
void copyDirectoryContents(Directory original, Directory copy) {
  String originalPath = original.path;
  String copyPath = copy.path;

  original.listSync().forEach((listing) {
    if (listing is File) {
      File originalFile = listing as File;

      // File.name outputs the full path
      // Convert '\' to '/' since Windows uses '\' as a separator
      // Determine the filename by looking at the last '/'. This works since
      // the traversal is not recursive
      String fullPath = originalFile.path.replaceAll('\\', '/');
      String filename = fullPath.substring(fullPath.lastIndexOf('/'));

      // Create the new File
      String copyFilePath = '$copyPath/$filename';
      File copyFile = new File(copyFilePath);
      copyFile.createSync();

      // Copy the file
      copyFileContents(originalFile, copyFile);
    }
  });
}

/// Delete the contents of the directory.
void deleteDirectoryContents(Directory directory) {
  directory.listSync().forEach((listing) {
    if (listing is File) {
      File file = listing as File;

      file.deleteSync();
    }
  });

  directory.deleteSync();
}

//---------------------------------------------------------------------
// Test functions
//---------------------------------------------------------------------

/// Compares the contents of the [AssetPackFile] vs the given [directory].
void checkPackFile(AssetPackFile assetPack, Directory directory) {
  List<String> filePaths = new List<String>();
  int directoryPathLength = directory.path.length;

  // Check that all files are present
  directory.listSync(recursive: true).forEach((listing) {
    if (listing is File) {
      File file = listing as File;

      // Get the relative path
      // Make sure the path separator is '/'
      String relativeFilePath = file.absolute.path.substring(directoryPathLength + 1);
      relativeFilePath = relativeFilePath.replaceAll('\\', '/');

      // ignore generated "directory/_.pack"
      if (relativeFilePath != '_.pack') {
        filePaths.add(relativeFilePath);
      }
    }
  });

  expect(assetPack.assets.values.map((x) => x.url), unorderedEquals(filePaths));

  // Check that each individual file is contained in the pack
  assetPack.assets.values.forEach((value) {
    expect(filePaths, contains(value.url));
  });
}

/// Compares the contents of two [AssetPackFile]s.
void comparePackFiles(AssetPackFile actual, AssetPackFile expected) {
  expect(actual.toJson(), equals(expected.toJson()));
}

/// Runs an individual test
PackgenTest newPackgenTest(String name, Directory directory, dynamic onStartup, dynamic onTest) => (n){
  debug(">>>>>>>>>>>>>>>>>> ${name}");

  // Run the function to setup the environment
  onStartup();

  var cb = (ProcessResult r) {
    debug("${name} : exit : ${r.exitCode}");
    debug("${name} : out : ${r.stdout}");
    debug("${name} : err : ${r.stderr}");
    var generatedPackFile = openAssetPackFile('${directory.path}/_.pack');
    onTest(generatedPackFile, directory);
    testComplete(name, n + 1);
    return n + 1;
  };
  return Process.run('dart', ['bin/packgen.dart', directory.path]).then(cb);
};

/// Runs the individual tests.
///
/// Each test requires an asynchronous operation, this is the packgen process,
/// to occur. And each test needs to be run in succession. This function is a
/// hack to ensure this happens.
void runTest(List<PackgenTest> tests) {
  test('run sequence of operations',() {
    var f = tests.fold(new Future.value(0), (acc, x) => acc.then(x));
    f.then(expectAsync((n) => expect(n, tests.length)));
  });
}

void main() {
  // Copy the directory to a temporary one
  // Working directory is the root asset_pack dir by default
  // Directory.path does not give the full path unless the full path is
  // specified. There's also no way to get the full path so use the working
  // directory to get the full path because File.name has the full path.
  Directory workingDirectory = Directory.current;
  String currentPath = workingDirectory.path;

  Directory original = new Directory(path.join(currentPath, 'test/testpack'));
  Directory originalSubpack =
      new Directory(path.join(currentPath, 'test/testpack/subpack'));
  Directory originalJson =
      new Directory(path.join(currentPath, 'test/testpack/json'));
  Directory originalText =
      new Directory(path.join(currentPath, 'test/testpack/text'));

  Directory copy = new Directory(path.join(currentPath, 'test/testpack_copy'));
  Directory copySubpack =
      new Directory(path.join(currentPath, 'test/testpack_copy/subpack'));
  Directory copyJson =
      new Directory(path.join(currentPath, 'test/testpack_copy/json'));
  Directory copyText =
      new Directory(path.join(currentPath, 'test/testpack_copy/text'));
  copy.createSync();

  List<PackgenTest> tests = new List<PackgenTest>();
  PackgenTestStartup setup;

  Function clearCopy = () {
    if (copy.existsSync()) {
      copy.deleteSync(recursive: true);
    }
    copy.createSync(recursive: true);
  };

  tests.add(newPackgenTest('empty file', copy, clearCopy, checkPackFile));
  tests.add(newPackgenTest('single file', copy, () {
    copyDirectoryContents(original, copy); }, checkPackFile));

  // Add the subpack directory
  Function subpackCreate = () {
    copySubpack.createSync();
    copyDirectoryContents(originalSubpack, copySubpack);
  };

  tests.add(newPackgenTest('subpack', copy, subpackCreate, checkPackFile));

  // Add the JSON directory
  Function jsonCreate = () {
    copyJson.createSync();
    copyDirectoryContents(originalJson, copyJson);
  };

  tests.add(newPackgenTest('subpack + json', copy, jsonCreate, checkPackFile));

  // Add the text directory
  Function textCreate = () {
    copyText.createSync();
    copyDirectoryContents(originalText, copyText);
  };

  // Add an additional check that compares the asset pack file
  Function compareOutput = (AssetPackFile assetPack, Directory directory) {
    AssetPackFile expected = openAssetPackFile('test/testpack_expected.pack');

    checkPackFile(assetPack, directory);
    comparePackFiles(assetPack, expected);
  };

  tests.add(newPackgenTest('subpack + json + text', copy, textCreate, compareOutput));

  // Remove the test directory
  Function textDelete = () {
    deleteDirectoryContents(copyText);
  };

  tests.add(newPackgenTest('subpack + json - text', copy, textDelete, checkPackFile));

  // Remove the json directory
  Function jsonDelete = () {
    deleteDirectoryContents(copyJson);
  };

  tests.add(newPackgenTest('subpack - json - text', copy, jsonDelete, checkPackFile));

  // Remove the subpack directory
  Function subpackDelete = () {
    deleteDirectoryContents(copySubpack);
  };

  tests.add(newPackgenTest('-subpack - json - text', copy, subpackDelete, checkPackFile));

  // Not a test but lets us cleanup after all the tests are complete
  tests.add((n) {
    deleteDirectoryContents(copy);
    return new Future.value(n+1);
  });

  runTest(tests);
}
