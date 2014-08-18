library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

//import '../test/test_dump_render_tree.dart' as test_dump_render_tree;

void main(List<String> args) {

  //
  // Analyzer
  //
  addTask('analyze_lib', createAnalyzerTask(['lib/asset_pack_common.dart',
                                             'lib/asset_pack_browser.dart',
                                             'lib/asset_pack_standalone.dart']));

  addTask('analyze_test', createAnalyzerTask(['test/tests.dart']));

  //
  // Unit test headless browser
  //
  //addTask('headless_test', createUnitTestTask(test_dump_render_tree.testCore));

  runHop(args);
}
