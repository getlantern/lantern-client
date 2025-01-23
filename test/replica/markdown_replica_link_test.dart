

void main() {

}


// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lantern/features/replica/logic/api.dart';
// import 'package:lantern/features/replica/logic/markdown_link_builder.dart';
// import 'package:markdown/markdown.dart' as md;


// // XXX <06-12-21, soltzen> Discussion here as to why use flutter_markdown and
// // markdown packages:
// // https://github.com/getlantern/android-lantern/pull/499#discussion_r763046560
//
// Widget boilerplate(Widget child) {
//   // XXX <10-11-21, soltzen> This specific tree is required for rendering
//   // MarkdownBody in widget testing. The same boilerplate is used in
//   // flutter_markdown package testing:
//   // https://github.com/flutter/packages/blob/2cbc815b90aedd274a2d39563a40152d8593dd06/packages/flutter_markdown/test/scrollable_test.dart#L22
//   return MediaQuery(
//     data: const MediaQueryData(),
//     child: MaterialApp(
//       home: Directionality(
//         textDirection: TextDirection.ltr,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [child],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// // TODO <08-08-22, kalli> We might want to move this to integration tests and use our test driver library
// void main() {
//   testWidgets('Assert Replica links work in MarkdownBody',
//       (WidgetTester tester) async {
//     const data = '''
//   This is a markdown text blob. Only the links starting with replica:// count.
//
//   replica://
//     Nothing happens here: the link is empty
//
//   hello world!
//     Nothing happens here
//
//   bunnyfoofooreplica://
//     Nothing happens here
//
//   replica://bunnyfoofoo
//     This link does not count because it doesn't start with magnet:?xt=urn:btih:
//
//   replica://magnet:?xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
//     This link counts
//
//   replica://xt=urn:btih:6a9759bffd5c0af65319979fb7832189f4f3c35d&dn=sintel.mp4
//     This link does not count since it has no leading 'magnet:?'
//
//   magnet://xt=urn:btih:32729D0D089180D1095279069148DDC27323188B&dn=The%20Suicide%20Squad%20(2021)%20%5B1080p%5D%20%5BWEBRip%5D%20%5B5.1%5D%20&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2780%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2730%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&so=0
//     This link does not count because it has the wrong prefix
//
//   replica://magnet:?xt=urn:btih:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//     This link does count because we accept plain sha1 hexes
//
//   http://www.google.com
//     This link does not count
//
//   A link at the end of the text also works
//         replica://magnet:?xt=urn:btih:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB''';
//     final expectedInfohashes = <String>[
//       '6a9759bffd5c0af65319979fb7832189f4f3c35d',
//       'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
//       'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB',
//     ];
//
//     final actualInfohashes = <String>[];
//     await tester.pumpWidget(
//       boilerplate(
//         // XXX <06-12-2021> soltzen: make sure this is a MarkdownBody, else the
//         // rendering won't be scrollable (i.e., it won't be complete and the
//         // assertions won't see the links)
//         MarkdownBody(
//           data: data,
//           builders: {
//             'replica': ReplicaLinkMarkdownElementBuilder(
//               openLink: (replicaApi, link) {
//                 actualInfohashes.add(link.infohash);
//               },
//               // Use a ReplicaApi with fake address so that links actually
//               // render, otherwise ReplicaLinkMarkdownElementBuilder thinks
//               // Replica is disabled and won't render the links.
//               replicaApi: ReplicaApi(
//                 'http://localhost:8000',
//               ),
//             ),
//           },
//           inlineSyntaxes: <md.InlineSyntax>[ReplicaLinkSyntax()],
//           extensionSet: md.ExtensionSet.gitHubFlavored,
//         ),
//       ),
//     );
//
//     // Replica links are SelectableTexts. Loop through each's
//     // TapGestureRecognizer and tap it
//     for (final textWidget in tester.widgetList(find.byType(SelectableText))) {
//       var recognizer =
//           ((textWidget as SelectableText).textSpan as TextSpan).recognizer;
//       if (recognizer == null) {
//         continue;
//       }
//       (recognizer as TapGestureRecognizer).onTap!();
//     }
//
//     // Assert we tapped all the expected links
//     expect(actualInfohashes.length, equals(expectedInfohashes.length));
//     for (var i = 0; i < actualInfohashes.length; i++) {
//       expect(actualInfohashes[i], equals(expectedInfohashes[i]));
//     }
//   });
// }
