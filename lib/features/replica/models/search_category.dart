import 'package:lantern/common/ui/image_paths.dart';

enum SearchCategory { Image, Video, Audio, Document, App, News, Unknown }

// Taken mostly from here
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
// Anything not in this category is still acceptable, but we will just offer to
// share/download the file, not view it.
final Map<String, SearchCategory> mimeToCategory = {
// Image
  'image/jpg': SearchCategory.Image,
  'image/jpeg': SearchCategory.Image,
  'image/png': SearchCategory.Image,
  'image/gif': SearchCategory.Image,
  'image/webp': SearchCategory.Image,
  'image/tiff': SearchCategory.Image,
  'image/bmp': SearchCategory.Image,
// Video
  'video/mp4': SearchCategory.Video,
  'video/x-m4v': SearchCategory.Video,
  'video/x-matroska': SearchCategory.Video,
  'video/webm': SearchCategory.Video,
  'video/quicktime': SearchCategory.Video,
  'video/x-msvideo': SearchCategory.Video,
  'video/x-ms-wmv': SearchCategory.Video,
  'video/mpeg': SearchCategory.Video,
// Audio
  'audio/mpeg': SearchCategory.Audio,
  'audio/m4a': SearchCategory.Audio,
  'audio/ogg': SearchCategory.Audio,
  'audio/x-wav': SearchCategory.Audio,
// Document
  'application/epub+zip': SearchCategory.Document,
  'application/pdf': SearchCategory.Document,
};

extension ToShortString on SearchCategory {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension GetRelevantImagePath on SearchCategory {
  String getRelevantImagePath() {
    switch (this) {
      case SearchCategory.Image:
        return ImagePaths.image_inactive;
      case SearchCategory.Video:
        return ImagePaths.video_black;
      case SearchCategory.Audio:
        return ImagePaths.audio_black;
      case SearchCategory.Document:
        return ImagePaths.doc_black;
      case SearchCategory.App:
        return ImagePaths.zip_black;
      case SearchCategory.News:
      case SearchCategory.Unknown:
        return ImagePaths.unknown_black;
    }
  }
}

// Taken verbatim from
// https://github.com/getlantern/lantern-desktop/blob/cb5be6f661567ab53287e15b042a30e82c68aaa4/ui/src/models/replica.ts#L132
// XXX <21-12-2021> soltzen: there's no differentiation in lantern-desktop
// between different 'subtypes' of a category (i.e., picking only 'mp4' files,
// not all video filetypes). This might be a cool feature later.
//
// For App searches, we are more restrictive than desktop, limiting results to
// 'application/zip' or 'application/octet-stream' or
// 'application/vnd.android.package-archive' rather than all subtypes of
// 'application'.
extension MimeTypes on SearchCategory {
  String mimeTypes() {
    switch (this) {
      case SearchCategory.Image:
        return 'image';
      case SearchCategory.Video:
        return 'video%2Fmp4+video%2Fwebm+video%2Fogg+video%2Fmov';
      case SearchCategory.Audio:
        return 'audio+music+x-music';
      case SearchCategory.Document:
        return 'text+epub+application/pdf+rtf+word+spreadsheet+excel+xml';
      case SearchCategory.App:
        return 'message+www+chemical+model+paleovu+x-world+xgl+multipart+application/zip+application/octet-stream+application/vnd.android.package-archive';
      case SearchCategory.News:
      case SearchCategory.Unknown:
        // Web and Unknown don't use mime types
        return '';
    }
  }
}

SearchCategory SearchCategoryFromMimeType(String? contentType) {
  if (contentType == null || contentType.isEmpty) {
    return SearchCategory.Unknown;
  }
  if (mimeToCategory.containsKey(contentType.toLowerCase())) {
    return mimeToCategory[contentType.toLowerCase()]!;
  }
  return SearchCategory.Unknown;
}
