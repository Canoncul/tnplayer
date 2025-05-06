import 'package:obs_websocket/obs_websocket.dart';
import 'player.dart';
import 'obs_manager.dart';
import 'models/TNScene.dart';
import 'models/TNSceneItems.dart';

late ObsWebSocket obsWebSocket;

String currentProgramSceneName = "";
String currentProgramSceneUuid = "";

List<TNScene> scenes = [];
TNScene? mainScene;
List<TNSceneItems> mainSceneItems = [];

void main(List<String> arguments) {
  init();
}
