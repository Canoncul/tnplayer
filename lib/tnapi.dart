import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:tnplayer/tnplayer.dart';
import 'models/MediaFile.dart';

class TNApi {
  static Future<MediaFile?> randomMediaFile() async {
    MediaFile? mediaFile = await TNApi.getMedia();
    return mediaFile;
  }

  static Future<MediaFile?> getMedia() async {
    final dio = Dio();
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: printError, // specify log function (optional)
      retries: 30, // retry count (optional)
      // retryDelays: const [
      //   // set delays between retries (optional)
      //   Duration(seconds: 1), // wait 1 sec before first retry
      //   Duration(seconds: 2), // wait 2 sec before second retry
      //   Duration(seconds: 3), // wait 3 sec before third retry
      // ],
    ));
    try {
      isWaitingApi = true;
      Response response = await dio.post('https://dev.tunenight.app/getRandomMediaForStream', data: {});
      // print(response.data);
      String strJson = response.data.toString();
      Map<String, dynamic> resultObj = jsonDecode(strJson)["result"];
      MediaFile mediaFile = MediaFile(
        artist: resultObj["artist"],
        title: resultObj["title"],
        venue: resultObj["venue"],
        url: resultObj["url"],
      );
      isWaitingApi = false;
      return mediaFile;
    } catch (e) {
      print(e);
    }
    isWaitingApi = false;
    return null;
  }

  static printError(String message) {
    apiErrorCounter++;
    print("Error: $message");
  }
}
