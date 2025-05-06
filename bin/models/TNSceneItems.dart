import 'TNSceneItemTransform.dart';
import '../const.dart';

enum TNInputType {
  input,
  background,
  info,
  other,
}

class TNSceneItems {
  String inputKind;
  dynamic isGroup;
  String sceneItemBlendMode;
  bool sceneItemEnabled;
  int sceneItemId;
  int sceneItemIndex;
  bool sceneItemLocked;
  TNSceneItemTransform sceneItemTransform;
  String sourceName;
  String sourceType;
  String sourceUuid;

  TNSceneItems({
    required this.inputKind,
    required this.isGroup,
    required this.sceneItemBlendMode,
    required this.sceneItemEnabled,
    required this.sceneItemId,
    required this.sceneItemIndex,
    required this.sceneItemLocked,
    required this.sceneItemTransform,
    required this.sourceName,
    required this.sourceType,
    required this.sourceUuid,
  });

  static TNSceneItems fromMap(Map<String, dynamic> map) {
    return TNSceneItems(
      inputKind: map['inputKind'] ?? '',
      isGroup: map['isGroup'] ?? false,
      sceneItemBlendMode: map['sceneItemBlendMode'] ?? '',
      sceneItemEnabled: map['sceneItemEnabled'] ?? true,
      sceneItemId: map['sceneItemId'] ?? 0,
      sceneItemIndex: map['sceneItemIndex'] ?? 0,
      sceneItemLocked: map['sceneItemLocked'] ?? false,
      sceneItemTransform: TNSceneItemTransform.fromMap(map['sceneItemTransform']),
      sourceName: map['sourceName'] ?? '',
      sourceType: map['sourceType'] ?? '',
      sourceUuid: map['sourceUuid'] ?? '',
    );
  }

  get itemType {
    if (inputKind == "image_source") {
      return TNInputType.background;
    } else if (inputKind == "ffmpeg_source") {
      return TNInputType.input;
    } else if (inputKind == 'text_ft2_source_v2') {
      return TNInputType.info;
    }
    return TNInputType.other;
  }

  @override
  String toString() {
    return 'TNSceneItems{inputKind: $inputKind, isGroup: $isGroup, sceneItemBlendMode: $sceneItemBlendMode, sceneItemEnabled: $sceneItemEnabled, sceneItemId: $sceneItemId, sceneItemIndex: $sceneItemIndex, sceneItemLocked: $sceneItemLocked, sceneItemTransform: $sceneItemTransform, sourceName: $sourceName, sourceType: $sourceType, sourceUuid: $sourceUuid}';
  }
}
