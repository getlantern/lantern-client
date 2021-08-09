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

String getMimeFromExtension(String fileExtension) {
  if (audioMimes.toString().contains(fileExtension)) return 'audio';
  if (videoMimes.toString().contains(fileExtension)) return 'video';
  if (imageMimes.toString().contains(fileExtension)) return 'image';
  return '';
}

List<String> getExtensionFromMimeList(List<String> list) =>
    list.map((val) => val.split('/')[1]).toList();
