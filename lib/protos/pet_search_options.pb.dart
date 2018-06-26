///
//  Generated code. Do not modify.
///
// ignore_for_file: non_constant_identifier_names,library_prefixes

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart';

class PetSearchOptions extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('PetSearchOptions')
    ..pPS(1, 'breeds')
    ..pPS(2, 'ages')
    ..pPS(3, 'sizes')
    ..aOB(4, 'fixedOnly')
    ..aOB(5, 'includeBreeds')
    ..aOS(6, 'sex')
    ..pPS(7, 'selectedShelters')
    ..aOS(8, 'zip')
    ..aOS(9, 'animalType')
    ..a<int>(10, 'maxDistance', PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  PetSearchOptions() : super();
  PetSearchOptions.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  PetSearchOptions.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  PetSearchOptions clone() => new PetSearchOptions()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;
  static PetSearchOptions create() => new PetSearchOptions();
  static PbList<PetSearchOptions> createRepeated() => new PbList<PetSearchOptions>();
  static PetSearchOptions getDefault() {
    if (_defaultInstance == null) _defaultInstance = new _ReadonlyPetSearchOptions();
    return _defaultInstance;
  }
  static PetSearchOptions _defaultInstance;
  static void $checkItem(PetSearchOptions v) {
    if (v is! PetSearchOptions) checkItemFailed(v, 'PetSearchOptions');
  }

  List<String> get breeds => $_getList(0);

  List<String> get ages => $_getList(1);

  List<String> get sizes => $_getList(2);

  bool get fixedOnly => $_get(3, false);
  set fixedOnly(bool v) { $_setBool(3, v); }
  bool hasFixedOnly() => $_has(3);
  void clearFixedOnly() => clearField(4);

  bool get includeBreeds => $_get(4, false);
  set includeBreeds(bool v) { $_setBool(4, v); }
  bool hasIncludeBreeds() => $_has(4);
  void clearIncludeBreeds() => clearField(5);

  String get sex => $_getS(5, '');
  set sex(String v) { $_setString(5, v); }
  bool hasSex() => $_has(5);
  void clearSex() => clearField(6);

  List<String> get selectedShelters => $_getList(6);

  String get zip => $_getS(7, '');
  set zip(String v) { $_setString(7, v); }
  bool hasZip() => $_has(7);
  void clearZip() => clearField(8);

  String get animalType => $_getS(8, '');
  set animalType(String v) { $_setString(8, v); }
  bool hasAnimalType() => $_has(8);
  void clearAnimalType() => clearField(9);

  int get maxDistance => $_get(9, 0);
  set maxDistance(int v) { $_setSignedInt32(9, v); }
  bool hasMaxDistance() => $_has(9);
  void clearMaxDistance() => clearField(10);
}

class _ReadonlyPetSearchOptions extends PetSearchOptions with ReadonlyMessageMixin {}

