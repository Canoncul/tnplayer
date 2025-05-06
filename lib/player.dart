import 'models/MediaFile.dart';
import 'demo_data.dart';
import 'dart:math';
import 'tnplayer.dart';
import 'tnapi.dart';

Future<MediaFile> randomMediaFile() async {
  MediaFile mediaFile = await Tnapi.getMedia();
  // int randomIndex = Random().nextInt(mediaFiles.length);
  // print("Random Index : " + randomIndex.toString());
  // MediaFile mediaFile = mediaFiles[randomIndex];
  return mediaFile;
}

playVideo() async {
  // print("Handshake :" + obsWebSocket!.handshakeComplete.toString());
  // var response = await obsWebSocket.send('GetSceneItemList');
  // dynamic inputs = response?.responseData;
  // if (inputs != null) {
  //   inputs["inputs"].forEach((input) {
  //     print('${input.toString()}');
  //   });
  // }
  var response = await obsWebSocket.send('GetCurrentProgramScene');

  Map<String, dynamic>? scene = response?.responseData;

  //print(scene.toString());

  if (scene != null) {
    currentProgramSceneName = scene['currentProgramSceneName'];
    currentProgramSceneUuid = scene['currentProgramSceneUuid'];
    String sceneName = scene['sceneName'];
    String sceneUuid = scene['sceneUuid'];

    var query = {
      'sceneName': currentProgramSceneName,
      'sceneUuid': currentProgramSceneUuid,
    };
    var responseItemList = await obsWebSocket.send('GetSceneItemList', query);
    //Map<String, dynamic>? sceneItemList = responseItemList?.responseData;

    // if (sceneItemList != null && (sceneItemList['sceneItems'] as List<dynamic>).isNotEmpty) {
    //Map<String, dynamic>? sceneItem = sceneItemList!['sceneItems'][0];
    // add new video source
    // addSource();
    // set position
    var querySetPosition = {
      'sceneName': currentProgramSceneName,
      'sceneUuid': currentProgramSceneUuid,
      'sceneItemId': 6,
      'sceneItemTransform': {
        // "alignment": 1,
        // "boundsAlignment": 0,
        "boundsHeight": 960,
        "boundsType": "OBS_BOUNDS_SCALE_TO_HEIGHT",
        "boundsWidth": 540,
        "cropBottom": 0,
        "cropLeft": 0,
        "cropRight": 0,
        "cropTop": 0,
        // "height": 61.90977478027344,
        "positionX": 0,
        "positionY": 0,
        //"rotation": 0.0,
        // "scaleX": 10,
        // "scaleY": 10,
        "sourceHeight": 960.0,
        "sourceWidth": 540.0,
        "width": 540,
        "height": 960,
      }
    };
    var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
    print("Result SetSceneItemTransform : " + (responseSetPosition?.requestStatus.comment ?? "Error"));
    // } else {
    //   print('No scene items found.');
    // }
    // add new item to scene
    // var queryNew = {
    //   'sceneName': currentProgramSceneName,
    //   'sceneUuid': currentProgramSceneUuid,
    //   'sourceName': 'hehe',
    //   'sourceKind': 'ffmpeg_source',
    //   'sourceSettings': {
    //     'input':
    //         'https://tunenight.s3.amazonaws.com/bc284729d9afdc4f7c6d1677ea6c04bd_d5574ad0-ca10-11ef-8ed1-17e3b69f17bc-a9ncey0p1735935835672381.mp4',
    //     //'file': '/Users/canoncul/Desktop/vtest/output.mp4',
    //     'looping': true,
    //   },
    // };
    // var responseSetSourcePrivateSettings = await obsWebSocket.send("SetSourcePrivateSettings", queryNew);
    // print(responseSetSourcePrivateSettings);
  }

  //print(obsWebSocket.sources.toString());
  //scenes.forEach((scene) => print('${scene['sceneName']} - ${scene['sceneIndex']}'));
  // String video = await tnplayer.nextVideo();
  //print(video);
  //print("Command : " + getCommand());
  // var result = await Process.run(
  //   'ffmpeg',
  //   ['-version'], // Burada ffmpeg'in versiyon bilgisini alıyoruz
  //   runInShell: true, // Komut satırında çalıştırılmasını sağlıyoruz
  // );
  // if (result.exitCode == 0) {
  //   print('FFmpeg komutu başarıyla çalıştırıldı:');
  //   print(result.stdout); // Çıktıyı ekrana basıyoruz
  // } else {
  //   print('FFmpeg komutu çalıştırılamadı:');
  //   print(result.stderr); // Hata mesajını yazdırıyoruz
  // }
  Duration duration = Duration(seconds: 5);
  await Future.delayed(duration);
}
