import 'package:tnplayer/tnapi.dart';
import 'package:tnplayer/utils.dart';
import 'package:uuid/uuid.dart';
import 'tnplayer.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'models/MediaFile.dart';
import 'models/TNScene.dart';
import 'const.dart';
import 'models/TNSceneItems.dart';

Future<void> init() async {
  print("Begin Time : $beginTime");
  obsWebSocket = await ObsWebSocket.connect(
    'ws://127.0.0.1:4455',
    password: '12341234',
    fallbackEventHandler: (Event event) async {
      //print('type: ${event.eventType} data: ${event.eventData}');
      if (event.eventType == 'MediaInputPlaybackStarted') {
        //print('MediaInputPlaybackStarted');
      } else if (event.eventType == 'MediaInputPlaybackEnded') {
        //print('MediaInputPlaybackEnded');
        if (isWaitingApi == false) {
          MediaFile? nextMedia = await TNApi.randomMediaFile();
          if (nextMedia != null) {
            await addVideoSource(nextMedia);
            Duration duration = DateTime.now().difference(beginTime);
            print(
                "Next Media : ${nextMedia.toString()} Stream Duration : ${duration.inMinutes} minutes - Play Counter : $playCounter - Api Error Counter : $apiErrorCounter");
          }
        } else {
          print("Waiting for API");
          // show error ui
        }
      } else {
        // print('Event: ${event.eventType} data: ${event.eventData}');
      }
    },
  );
  await obsWebSocket.subscribe(EventSubscription.all);
  await checkScenes();
  MediaFile? mediaFile = await TNApi.randomMediaFile();
  if (mediaFile != null) {
    print("First Media : ${mediaFile.toString()}");
    await addVideoSource(mediaFile);
  }
}

String sourceName() {
  return Uuid().v1();
}

addVideoSource(MediaFile mediaFile) async {
  playCounter++;
  await clearVideoSource();
  String randomId = sourceName();
  var querySource = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'inputKind': 'ffmpeg_source',
    'inputName': randomId,
    'inputSettings': {
      "is_local_file": false,
      'input': mediaFile.url,
      "looping": false,
      "buffering_mb": 3,
      "restart_on_activate": false,
    },
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', querySource);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  responseToString(responseCreateInput, "addVideoSource");
  int sceneItemId = sceneItemResponse!['sceneItemId'];
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
      "positionX": 0,
      "positionY": 0,
      "scaleX": 1.0,
      "scaleY": 1.0,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  responseToString(responseSetPosition, "addVideoSourceSetSceneItemTransform");
  await addDecorationBox(randomId);
  addInfoSource(randomId, mediaFile);
}

addDecorationBox(String id) async {
  var query = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'inputKind': 'color_source_v3',
    'inputName': "BoxLayer-$id",
    'inputSettings': {
      "color": 4278190080,
      "width": 540,
      "height": 75,
    },
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', query);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  responseToString(responseCreateInput, "addDecorationBox");
  int sceneItemId = sceneItemResponse!['sceneItemId'];
  var querySetPosition = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sceneItemId': sceneItemId,
    'sceneItemTransform': {
      "positionX": 0,
      "positionY": 885,
      "scaleX": 1.0,
      "scaleY": 1.0,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  responseToString(responseSetPosition, "addDecorationBoxSetSceneItemTransform");
}

addInfoSource(String id, MediaFile mediaFile) async {
  var query = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'inputKind': 'text_ft2_source_v2',
    'inputName': "TextLayer-$id",
    'inputSettings': {
      "text": "Performer : ${mediaFile.artist}\nVenue : ${mediaFile.venue}\n${mediaFile.titleStr()}",
      "font": {"face": "Krungthep", "style": "Regular", "size": 18, "flags": 1}
    },
  };
  var responseCreateInput = await obsWebSocket.send('CreateInput', query);
  Map<String, dynamic>? sceneItemResponse = responseCreateInput?.responseData;
  responseToString(responseCreateInput, "addInfoSource");
  int sceneItemId = sceneItemResponse!['sceneItemId'];
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
      "positionX": 30,
      "positionY": 890,
      //"rotation": 0.0,
      "scaleX": 1.0,
      "scaleY": 1.0,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  responseToString(responseSetPosition, "addInfoSourceSetSceneItemTransform");
}

clearVideoSource() async {
  await getSceneItems(mainScene!);
  for (int i = 0; i < mainSceneItems.length; i++) {
    if (mainSceneItems[i].itemType == TNInputType.input ||
        mainSceneItems[i].itemType == TNInputType.info ||
        mainSceneItems[i].itemType == TNInputType.box) {
      var query = {
        'sceneName': mainScene!.sceneName,
        'sceneUuid': mainScene!.sceneUuid,
        'sceneItemId': mainSceneItems[i].sceneItemId,
      };
      var responseClearVideoSource = await obsWebSocket.send('RemoveSceneItem', query);
      responseToString(responseClearVideoSource, "clearVideoSource");
    }
  }
  await getSceneItems(mainScene!);
}

createScene(String sceneName) async {
  var query = {
    'sceneName': sceneName,
  };
  var responseCreateScene = await obsWebSocket.send('CreateScene', query);
  responseToString(responseCreateScene, "createScene");
  await getSceneList();
}

clearSources() async {
  var query = {
    'sceneName': currentProgramSceneName,
    'sceneUuid': currentProgramSceneUuid,
  };
  var responseClearSources = await obsWebSocket.send('RemoveSceneItem', query);
  responseToString(responseClearSources, "clearSources");
}

checkScenes() async {
  await getSceneList();
  await checkMainScene();
  await deleteUnusedScenes();
  await initSceneItems();
}

initSceneItems() async {
  await clearMainSceneItems();
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
  responseToString(responseCreateInput, "addBackground");
  int sceneItemId = sceneItemResponse!['sceneItemId'];
  var querySetPosition = {
    'sceneName': mainScene!.sceneName,
    'sceneUuid': mainScene!.sceneUuid,
    'sceneItemId': sceneItemId,
    'sceneItemTransform': {
      "boundsHeight": 960,
      "boundsType": "OBS_BOUNDS_SCALE_TO_WIDTH",
      "boundsWidth": 540,
      "cropBottom": 0,
      "cropLeft": 0,
      "cropRight": 0,
      "cropTop": 0,
      "positionX": 0,
      "positionY": 0,
      "sourceHeight": 960.0,
      "sourceWidth": 540.0,
      "width": 540,
      "height": 960,
    }
  };
  var responseSetPosition = await obsWebSocket.send('SetSceneItemTransform', querySetPosition);
  responseToString(responseSetPosition, "addBackgroundSetSceneItemTransform");
}

deleteUnusedScenes() async {
  for (int i = 0; i < scenes.length; i++) {
    if (scenes[i].sceneName != mainSceneName) {
      var query = {
        'sceneName': scenes[i].sceneName,
        'sceneUuid': scenes[i].sceneUuid,
      };
      var responseDeleteScene = await obsWebSocket.send('RemoveScene', query);
      responseToString(responseDeleteScene, "deleteUnusedScenes");
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
  responseToString(responseSceneList, "getSceneList");
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
    responseToString(responseClearMainSceneItems, "clearMainSceneItems");
  }
}

getSceneItems(TNScene scene) async {
  mainSceneItems.clear();
  var query = {
    'sceneName': scene.sceneName,
    'sceneUuid': scene.sceneUuid,
  };
  var responseGetInputs = await obsWebSocket.send('GetSceneItemList', query);
  responseToString(responseGetInputs, "getSceneItems");
  var inputs = responseGetInputs?.responseData?["sceneItems"];
  if (inputs != null) {
    for (int i = 0; i < inputs.length; i++) {
      TNSceneItems input = TNSceneItems.fromMap(inputs[i]);
      mainSceneItems.add(input);
    }
  }
}
