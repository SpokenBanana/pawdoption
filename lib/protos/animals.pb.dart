///
//  Generated code. Do not modify.
///
// ignore_for_file: non_constant_identifier_names,library_prefixes

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart';

class AnimalData extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('AnimalData')
    ..aOS(1, 'name')
    ..aOS(2, 'gender')
    ..aOS(3, 'breed')
    ..aOS(4, 'age')
    ..pPS(5, 'imgUrl')
    ..aOS(6, 'id')
    ..aOS(7, 'shelterId')
    ..aOS(8, 'apiId')
    ..aOS(9, 'cityState')
    ..pPS(10, 'options')
    ..aOS(11, 'size')
    ..aOS(12, 'lastUpdated')
    ..aOS(13, 'color')
    ..aOS(14, 'thumbUrl')
    ..aOS(15, 'description')
    ..hasRequiredFields = false
  ;

  AnimalData() : super();
  AnimalData.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  AnimalData.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  AnimalData clone() => new AnimalData()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static AnimalData create() => new AnimalData();
  static PbList<AnimalData> createRepeated() => new PbList<AnimalData>();
  static AnimalData getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyAnimalData();
    return _defaultInstance;
  }
  static AnimalData _defaultInstance;
  static void $checkItem(AnimalData v) {
    if (v is! AnimalData) checkItemFailed(v, 'AnimalData');
  }

  String get name => $_getS(0, '');
  set name(String v) { $_setString(0, v); }
  bool hasName() => $_has(0);
  void clearName() => clearField(1);

  String get gender => $_getS(1, '');
  set gender(String v) { $_setString(1, v); }
  bool hasGender() => $_has(1);
  void clearGender() => clearField(2);

  String get breed => $_getS(2, '');
  set breed(String v) { $_setString(2, v); }
  bool hasBreed() => $_has(2);
  void clearBreed() => clearField(3);

  String get age => $_getS(3, '');
  set age(String v) { $_setString(3, v); }
  bool hasAge() => $_has(3);
  void clearAge() => clearField(4);

  List<String> get imgUrl => $_getList(4);

  String get id => $_getS(5, '');
  set id(String v) { $_setString(5, v); }
  bool hasId() => $_has(5);
  void clearId() => clearField(6);

  String get shelterId => $_getS(6, '');
  set shelterId(String v) { $_setString(6, v); }
  bool hasShelterId() => $_has(6);
  void clearShelterId() => clearField(7);

  String get apiId => $_getS(7, '');
  set apiId(String v) { $_setString(7, v); }
  bool hasApiId() => $_has(7);
  void clearApiId() => clearField(8);

  String get cityState => $_getS(8, '');
  set cityState(String v) { $_setString(8, v); }
  bool hasCityState() => $_has(8);
  void clearCityState() => clearField(9);

  List<String> get options => $_getList(9);

  String get size => $_getS(10, '');
  set size(String v) { $_setString(10, v); }
  bool hasSize() => $_has(10);
  void clearSize() => clearField(11);

  String get lastUpdated => $_getS(11, '');
  set lastUpdated(String v) { $_setString(11, v); }
  bool hasLastUpdated() => $_has(11);
  void clearLastUpdated() => clearField(12);

  String get color => $_getS(12, '');
  set color(String v) { $_setString(12, v); }
  bool hasColor() => $_has(12);
  void clearColor() => clearField(13);

  String get thumbUrl => $_getS(13, '');
  set thumbUrl(String v) { $_setString(13, v); }
  bool hasThumbUrl() => $_has(13);
  void clearThumbUrl() => clearField(14);

  String get description => $_getS(14, '');
  set description(String v) { $_setString(14, v); }
  bool hasDescription() => $_has(14);
  void clearDescription() => clearField(15);
}

class _ReadonlyAnimalData extends AnimalData with ReadonlyMessageMixin {}

