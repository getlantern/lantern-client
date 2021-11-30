import 'dart:convert';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/app_item.dart';
import 'package:lantern/replica/models/audio_item.dart';
import 'package:lantern/replica/models/document_item.dart';
import 'package:lantern/replica/models/image_item.dart';
import 'package:lantern/replica/models/video_item.dart';
import 'package:lantern/replica/models/web_item.dart';
import 'package:lantern/replica/ui/searchcategory.dart';

class ReplicaSearchItem {
  ReplicaSearchItem({this.replicaLink, required this.displayName});
  ReplicaLink? replicaLink;
  String displayName;

  static List<ReplicaSearchItem> fromJson(
      SearchCategory category, String jsonBody) {
    Map<String, dynamic> body = jsonDecode(jsonBody);
    var serverError = body['error'];
    if (serverError != null) {
      throw Exception(serverError);
    }

    switch (category) {
      case SearchCategory.Web:
        return ReplicaWebItem.fromJson(body);
      case SearchCategory.Video:
        return ReplicaVideoItem.fromJson(body);
      case SearchCategory.Audio:
        return ReplicaAudioItem.fromJson(body);
      case SearchCategory.Image:
        return ReplicaImageItem.fromJson(body);
      case SearchCategory.Document:
        return ReplicaDocumentItem.fromJson(body);
      case SearchCategory.App:
        return ReplicaAppItem.fromJson(body);
      case SearchCategory.Unknown:
        // Should not happen: search items can't be unknown
        throw Exception('TODO');
    }
  }
}
