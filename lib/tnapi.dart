import 'dart:convert';

import 'package:dio/dio.dart';
import 'models/MediaFile.dart';

class Tnapi {
  static Future<MediaFile> getMedia() async {
    final dio = Dio();
    Response response = await dio.post('https://dev.tunenight.app/getRandomMediaForStream', data: {});
    //print(response.data);
    String strJson = response.data.toString();
    Map<String, dynamic> resultObj = jsonDecode(strJson)["result"];
    MediaFile mediaFile =
        MediaFile(artist: resultObj["artist"], title: resultObj["title"], venue: resultObj["venue"], url: resultObj["url"]);
    return mediaFile;
  }
}
