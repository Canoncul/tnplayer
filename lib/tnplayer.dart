import 'package:obs_websocket/obs_websocket.dart';
import 'obs_manager.dart';
import 'models/TNScene.dart';
import 'models/TNSceneItems.dart';

late ObsWebSocket obsWebSocket;

String currentProgramSceneName = "";
String currentProgramSceneUuid = "";

List<TNScene> scenes = [];
TNScene? mainScene;
List<TNSceneItems> mainSceneItems = [];
bool isWaitingApi = false;
DateTime beginTime = DateTime.now();
int playCounter = 0;
int apiErrorCounter = 0;

void main(List<String> arguments) {
  init();
}
