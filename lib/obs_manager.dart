import 'dart:io';

import 'package:uuid/uuid.dart';

import 'tnplayer.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'models/MediaFile.dart';
import 'player.dart';
import 'models/TNScene.dart';
import 'const.dart';
import 'models/TNSceneItems.dart';

Future<void> init() async {
  obsWebSocket = await ObsWebSocket.connect(
    'ws://192.168.0.10:4455',
    password: '12341234',
    fallbackEventHandler: (Event event) async {
      //print('type: ${event.eventType} data: ${event.eventData}');
      if (event.eventType == 'MediaInputPlaybackStarted') {
        print('MediaInputPlaybackStarted');
      } else if (event.eventType == 'MediaInputPlaybackEnded') {
        print('MediaInputPlaybackEnded');
        MediaFile nextMedia = await randomMediaFile();
        print("Next Media : " + nextMedia.url);
        addVideoSource(nextMedia);
      }
    },
  );
  await obsWebSocket.subscribe(EventSubscription.all);
  await checkScenes();
  MediaFile mediaFile = await randomMediaFile();
  print("First Media : " + mediaFile.url);
  await addVideoSource(mediaFile);
}

String sourceName() {
  return Uuid().v1();
}

addVideoSource(MediaFile mediaFile) async {
  print("after clean : $mainSceneItems");
  await clearVideoSource();
  print("Before clean : $mainSceneItems");
  //Duration duration = Duration(seconds: 15);
  //await Future.delayed(duration);
  String randomId = sourceName();
  var querySource = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'inputKind': 'ffmpeg_source',
    'inputName': randomId,
    'inputSettings': {"is_local_file": false, 'input': mediaFile.url, "looping": false},
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', querySource);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  print("Result addVideoSource : " + (responseCreateInput?.requestStatus.comment ?? "Error"));
  if (responseCreateInput!.requestStatus.result == false) {
    querySource = {
      'inputName': 'Input',
      'inputSettings': {"is_local_file": false, 'input': mediaFile.url, "looping": false},
    };
    responseCreateInput = await obsWebSocket.send('SetInputSettings', querySource);
  }
  if (sceneItemResponse != null) {
    print('Scene Item Added: ${sceneItemResponse.toString()}');
  }
  int sceneItemId = sceneItemResponse!['sceneItemId'];
  String sceneItemUuid = sceneItemResponse['inputUuid'];
  // var vs = await obsWebSocket.send('GetVideoSettings', {});
  // final baseW = vs?.responseData?['baseWidth'] as int;
  // final baseH = vs?.responseData?['baseHeight'] as int;
  var querySetPosition = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sceneItemId': sceneItemId,
    'sceneItemTransform': {
      "alignment": 5,
      "boundsAlignment": 5,
      "boundsHeight": 960,
      "boundsType": "OBS_BOUNDS_SCALE_INNER",
      "boundsWidth": 540,
      "cropBottom": 0,
      "cropLeft": 0,
      "cropRight": 0,
      "cropTop": 0,
      // "height": 61.90977478027344,
      "positionX": 0,
      "positionY": 0,
      //"rotation": 0.0,
      "scaleX": 1.0,
      "scaleY": 1.0,
      // "sourceHeight": 960.0,
      // "sourceWidth": 540.0,
      // "width": 540,
      // "height": 960,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  print("Result SetSceneItemTransform : " + (responseSetPosition?.requestStatus.comment ?? "Error"));
  addInfoSource(randomId, mediaFile);
}

addInfoSource(String id, MediaFile mediaFile) async {
  var query = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'inputKind': 'text_ft2_source_v2',
    'inputName': "TextLayer-$id",
    'inputSettings': {
      "text": "${mediaFile.artist} - @${mediaFile.venue}\n${mediaFile.title}",
      "font": {"face": "Krungthep", "style": "Regular", "size": 24, "flags": 1}
    },
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', query);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  print("Result addInfoSource : " + (responseCreateInput?.requestStatus.comment ?? "Error"));
  if (sceneItemResponse != null) {
    print('Scene Text Item Added: ${sceneItemResponse.toString()}');
  }
  int sceneItemId = sceneItemResponse!['sceneItemId'];
  String sceneItemUuid = sceneItemResponse['inputUuid'];
  var querySetPosition = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sceneItemId': sceneItemId,
    'sceneItemTransform': {
      "alignment": 5,
      "boundsAlignment": 5,
      "boundsHeight": 960,
      "boundsType": "OBS_BOUNDS_NONE",
      "boundsWidth": 540,
      "cropBottom": 0,
      "cropLeft": 0,
      "cropRight": 0,
      "cropTop": 0,
      // "height": 61.90977478027344,
      "positionX": 16,
      "positionY": 885,
      //"rotation": 0.0,
      "scaleX": 1.0,
      "scaleY": 1.0,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  print("Result SetSceneItemTransform : " + (responseSetPosition?.requestStatus.comment ?? "Error"));
}

clearVideoSource() async {
  await getSceneItems(mainScene!);
  for (int i = 0; i < mainSceneItems.length; i++) {
    print("Scene Item ID : ${mainSceneItems[i].sceneItemId} type : ${mainSceneItems[i].itemType}");
    if (mainSceneItems[i].itemType == TNInputType.input || mainSceneItems[i].itemType == TNInputType.info) {
      var query = {
        'sceneName': mainScene!.sceneName,
        'sceneUuid': mainScene!.sceneUuid,
        'sceneItemId': mainSceneItems[i].sceneItemId,
      };
      var responseClearVideoSource = await obsWebSocket.send('RemoveSceneItem', query);
      print("Result ClearVideoSource : ${responseClearVideoSource?.requestStatus.comment ?? "Error"}");
    }
  }
  await getSceneItems(mainScene!);
}

createScene(String sceneName) async {
  var query = {
    'sceneName': sceneName,
  };
  var responseCreateScene = await obsWebSocket.send('CreateScene', query);
  print("Result CreateScene ($sceneName): ${responseCreateScene?.requestStatus.comment ?? "Error"}");
  await getSceneList();
}

clearSources() async {
  var query = {
    'sceneName': currentProgramSceneName,
    'sceneUuid': currentProgramSceneUuid,
  };
  var responseClearSources = await obsWebSocket.send('RemoveSceneItem', query);
  print("Result ClearSources : ${responseClearSources?.requestStatus.comment ?? "Error"}");
}

checkScenes() async {
  await getSceneList();
  print("Scenes List : $scenes");
  await checkMainScene();
  await deleteUnusedScenes();
  await initSceneItems();
}

initSceneItems() async {
  await clearMainSceneItems();
  // add background
  await addBackground();
}

addBackground() async {
  var query = {
    'sceneName': mainSceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sourceName': 'Background',
    'inputKind': 'image_source',
    'inputName': 'Background',
    'inputSettings': {"file": "/Users/canoncul/Documents/Projeler/tunenight/appicon.png"},
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', query);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  print("Result : " + (responseCreateInput?.requestStatus.comment ?? "Error"));
  if (sceneItemResponse != null) {
    print('Scene Item Added: ${sceneItemResponse.toString()}');
  }
  int sceneItemId = sceneItemResponse!['sceneItemId'];
  String sceneItemUuid = sceneItemResponse['inputUuid'];

  print("Scene Item ID : $sceneItemId");
  print("Scene Item UUID : $sceneItemUuid");
  // set position
  var querySetPosition = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sceneItemId': sceneItemId,
    'sceneItemTransform': {
      // "alignment": 1,
      // "boundsAlignment": 0,
      "boundsHeight": 960,
      "boundsType": "OBS_BOUNDS_SCALE_TO_WIDTH",
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
  print("Result Backgroud SetSceneItemTransform : " + (responseSetPosition?.requestStatus.comment ?? "Error"));
}

deleteUnusedScenes() async {
  for (int i = 0; i < scenes.length; i++) {
    if (scenes[i].sceneName != mainSceneName) {
      var query = {
        'sceneName': scenes[i].sceneName,
        'sceneUuid': scenes[i].sceneUuid,
      };
      var responseDeleteScene = await obsWebSocket.send('RemoveScene', query);
      print("Result DeleteScene : ${responseDeleteScene?.requestStatus.comment ?? "Error"}");
    }
  }
}

getSceneList() async {
  scenes.clear();
  var query = {
    'sceneName': currentProgramSceneName,
    'sceneUuid': currentProgramSceneUuid,
  };
  var responseSceneList = await obsWebSocket.send('GetSceneList', query);
  print("Result GetSceneList : ${responseSceneList?.requestStatus.comment ?? "Error"}");
  var sceneList = responseSceneList?.responseData?["scenes"];
  if (sceneList != null) {
    for (int i = 0; i < sceneList.length; i++) {
      TNScene scene = TNScene.fromMap(sceneList[i]);
      scenes.add(scene);
    }
  }
}

checkMainScene() async {
  mainScene = null;
  for (int i = 0; i < scenes.length; i++) {
    if (scenes[i].sceneName == mainSceneName) {
      mainScene = scenes[i];
      break;
    }
  }
  if (mainScene == null) {
    await createScene(mainSceneName);
  } else {
    print("Main Scene already exists");
  }
  print("Main Scene : $mainScene");
}

clearMainSceneItems() async {
  await getSceneItems(mainScene!);
  for (int i = 0; i < mainSceneItems.length; i++) {
    var query = {
      'sceneName': mainScene!.sceneName,
      'sceneUuid': mainScene!.sceneUuid,
      'sceneItemId': mainSceneItems[i].sceneItemId,
    };
    var responseClearMainSceneItems = await obsWebSocket.send('RemoveSceneItem', query);
    print("Result ClearMainSceneItems : ${responseClearMainSceneItems?.requestStatus.comment ?? "Error"}");
  }
  print("Main Scene Items Before Delete: $mainSceneItems");
}

getSceneItems(TNScene scene) async {
  mainSceneItems.clear();
  var query = {
    'sceneName': scene.sceneName,
    'sceneUuid': scene.sceneUuid,
  };
  var responseGetInputs = await obsWebSocket.send('GetSceneItemList', query);
  //print("Result GetInputs : ${responseGetInputs?.requestStatus.comment ?? "Error"}");
  var inputs = responseGetInputs?.responseData?["sceneItems"];
  if (inputs != null) {
    for (int i = 0; i < inputs.length; i++) {
      TNSceneItems input = TNSceneItems.fromMap(inputs[i]);
      mainSceneItems.add(input);
    }
    //print("Main Scene Items : $mainSceneItems");
  }
}
