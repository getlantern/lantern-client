enum MimeType { VIDEO, AUDIO, IMAGE, UNKNOWN }

MimeType mimeTypeOf(String mimeType) {
  if (mimeType.isNotEmpty) {
    if (audioMimes.contains(mimeType)) return MimeType.AUDIO;
    if (imageMimes.contains(mimeType)) return MimeType.IMAGE;
    if (videoMimes.contains(mimeType)) return MimeType.VIDEO;
  }
  return MimeType.UNKNOWN;
}

// https://developer.android.com/guide/topics/media/media-formats
const List<String> audioMimes = [
  'application/ogg',
  'audio/ogg',
  'audio/mp3',
  'audio/m4a',
  'audio/flac',
  'audio/opus',
  'audio/aac',
  'audio/mp4',
  'audio/mkv',
  'audio/mpeg',
  'audio/vorbis',
];

const List<String> imageMimes = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/bpm',
  'image/gif',
  'image/webp',
  'image/wav',
  'image/heif',
  'image/heic',
];

const List<String> videoMimes = [
  'video/mp4',
  'video/mkv',
  'video/mov',
  'video/quicktime',
  'video/3gp',
  'video/webm',
  'video/ogg',
];
