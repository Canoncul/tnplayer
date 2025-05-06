import '../const.dart';

enum SceneType {
  main,
  other,
}

class TNScene {
  int sceneIndex;
  String sceneName;
  String sceneUuid;

  TNScene({
    required this.sceneIndex,
    required this.sceneName,
    required this.sceneUuid,
  });

  @override
  String toString() {
    return 'Scene{sceneIndex: $sceneIndex, sceneName: $sceneName, sceneUuid: $sceneUuid}';
  }

  //TODO: Geliştirilebilir
  get sceneType {
    if (sceneName == mainSceneName) {
      return SceneType.main;
    }
    return SceneType.other;
  }

  static TNScene fromMap(Map<String, dynamic> map) {
    return TNScene(
      sceneIndex: map['sceneIndex'] ?? 0,
      sceneName: map['sceneName'] ?? '',
      sceneUuid: map['sceneUuid'] ?? '',
    );
  }
}
