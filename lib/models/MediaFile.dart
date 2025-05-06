class MediaFile {
  String url;
  String title;
  String artist;
  String venue;

  MediaFile({
    required this.url,
    required this.title,
    required this.artist,
    required this.venue,
  });

  @override
  String toString() {
    return 'MediaFile{url: $url, title: $title, artist: $artist, venue: $venue}';
  }
}
