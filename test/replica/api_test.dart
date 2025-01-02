// import 'dart:io';
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:lantern/features/replica/logic/api.dart';
// import 'package:lantern/features/replica/models/search_category.dart';
// import 'package:logger/logger.dart';


void main() {

}
// Future<String> runDummyServer(String ip, String port) async {
//   var result = await Process.run('which', ['json-server']);
//   expect(
//     result.exitCode,
//     isZero,
//     reason:
//         'json-server not installed. See here https://github.com/typicode/json-server#getting-started',
//   );
//   final proc = await Process.run(
//     'bash',
//     [
//       './scripts/replica_test_assets/run.sh',
//       port,
//     ],
//     runInShell: true,
//   );
//   sleep(const Duration(seconds: 2));
//   // Check if the service is running: /heartbeat should always return 200 OK
//   final resp = await http.get(Uri.parse('http://$ip:$port/heartbeat'));
//   expect(resp.statusCode == 200, true);
//   return proc.stdout.toString().trim();
// }
//
// Future<void> killDummyServer(String pid) async {
//   if (pid.isEmpty) {
//     return;
//   }
//   await Process.run('kill', ['-9', pid]);
// }
//
// Future<void> main() async {
//   // Sets up a dummy json-server to run tests against it
//   var dummyServerPid = '';
//   tearDown(() async {
//     await killDummyServer(dummyServerPid);
//   });
//   setUp(() async {
//     HttpOverrides.global = null;
//     Logger.level = Level.verbose;
//     dummyServerPid = await runDummyServer('localhost', '3000');
//   });
//
//   test('Search data serialized to ReplicaSearchItem (and children) properly',
//       () async {
//     for (var cat in SearchCategory.values) {
//       var l = await ReplicaApi('http://localhost:3000')
//           // query, page number and language don't matter since we're running
//           // this against json-server, where the response values are already
//           // hard-coded.
//           .search('doesntmatter', cat, 0, 'en');
//       expect(l.length, isNonZero);
//     }
//   });
// }
