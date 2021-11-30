import 'package:lantern/replica/models/search_item.dart';

class ReplicaWebItem extends ReplicaSearchItem {
  ReplicaWebItem(this.title, this.displayLink, this.link, this.snippet)
      : super(displayName: displayLink);
  String title;
  String displayLink;
  String link;
  String snippet;

  static List<ReplicaWebItem> fromJson(Map<String, dynamic> body) {
    var items = <ReplicaWebItem>[];
    var results = body['organic_results'] as List<dynamic>;
    for (var result in results) {
      var displayLink = result['displayed_link'] as String;
      var link = result['link'] as String;
      var snippet = result['snippet'] as String;
      var title = result['title'] as String;
      items.add(ReplicaWebItem(title, displayLink, link, snippet));
    }
    return items;
  }
}
