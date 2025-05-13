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

  titleStr() {
    int position = title.indexOf("by ");
    String result = "";
    if (position != -1) {
      result = title.substring(0, position);
    } else {
      result = title;
    }
    // clear all parenteheses
    result = result.replaceAll(RegExp(r'\(.*?\)'), '');
    return result.trim();
  }
}
