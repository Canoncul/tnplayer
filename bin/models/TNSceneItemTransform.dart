class TNSceneItemTransform {
  int alignment;
  int boundsAlignment;
  double boundsHeight;
  String boundsType;
  double boundsWidth;
  int cropBottom;
  int cropLeft;
  int cropRight;
  bool cropToBounds;
  int cropTop;
  double height;
  double positionX;
  double positionY;
  double rotation;
  double scaleX;
  double scaleY;
  double sourceHeight;
  double sourceWidth;
  double width;

  TNSceneItemTransform({
    required this.alignment,
    required this.boundsAlignment,
    required this.boundsHeight,
    required this.boundsType,
    required this.boundsWidth,
    required this.cropBottom,
    required this.cropLeft,
    required this.cropRight,
    required this.cropToBounds,
    required this.cropTop,
    required this.height,
    required this.positionX,
    required this.positionY,
    required this.rotation,
    required this.scaleX,
    required this.scaleY,
    required this.sourceHeight,
    required this.sourceWidth,
    required this.width,
  });

  static TNSceneItemTransform fromMap(Map<String, dynamic> map) {
    return TNSceneItemTransform(
      alignment: map['alignment'] ?? 0,
      boundsAlignment: map['boundsAlignment'] ?? 0,
      boundsHeight: map['boundsHeight'] ?? 0.0,
      boundsType: map['boundsType'] ?? '',
      boundsWidth: map['boundsWidth'] ?? 0.0,
      cropBottom: map['cropBottom'] ?? 0,
      cropLeft: map['cropLeft'] ?? 0,
      cropRight: map['cropRight'] ?? 0,
      cropToBounds: map['cropToBounds'] ?? false,
      cropTop: map['cropTop'] ?? 0,
      height: map['height'] ?? 0.0,
      positionX: map['positionX'] ?? 0.0,
      positionY: map['positionY'] ?? 0.0,
      rotation: map['rotation'] ?? 0.0,
      scaleX: map['scaleX'] ?? 1.0,
      scaleY: map['scaleY'] ?? 1.0,
      sourceHeight: map['sourceHeight'] ?? 0.0,
      sourceWidth: map['sourceWidth'] ?? 0.0,
      width: map['width'] ?? 0.0,
    );
  }
}
