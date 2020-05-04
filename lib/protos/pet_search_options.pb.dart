///
//  Generated code. Do not modify.
//  source: pet_search_options.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PetSearchOptions extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PetSearchOptions', package: const $pb.PackageName('pawdoption'), createEmptyInstance: create)
    ..pPS(1, 'breeds')
    ..pPS(2, 'ages')
    ..pPS(3, 'sizes')
    ..aOB(4, 'fixedOnly')
    ..aOB(5, 'includeBreeds')
    ..aOS(6, 'sex')
    ..pPS(7, 'selectedShelters')
    ..aOS(8, 'zip')
    ..aOS(9, 'animalType')
    ..a<$core.int>(10, 'maxDistance', $pb.PbFieldType.O3)
    ..aOB(11, 'goodWithChildren')
    ..aOB(12, 'goodWithDogs')
    ..aOB(13, 'goodWithCats')
    ..pPS(14, 'coat')
    ..pPS(15, 'color')
    ..hasRequiredFields = false
  ;

  PetSearchOptions._() : super();
  factory PetSearchOptions() => create();
  factory PetSearchOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PetSearchOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PetSearchOptions clone() => PetSearchOptions()..mergeFromMessage(this);
  PetSearchOptions copyWith(void Function(PetSearchOptions) updates) => super.copyWith((message) => updates(message as PetSearchOptions));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PetSearchOptions create() => PetSearchOptions._();
  PetSearchOptions createEmptyInstance() => create();
  static $pb.PbList<PetSearchOptions> createRepeated() => $pb.PbList<PetSearchOptions>();
  @$core.pragma('dart2js:noInline')
  static PetSearchOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PetSearchOptions>(create);
  static PetSearchOptions _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get breeds => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get ages => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.String> get sizes => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get fixedOnly => $_getBF(3);
  @$pb.TagNumber(4)
  set fixedOnly($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFixedOnly() => $_has(3);
  @$pb.TagNumber(4)
  void clearFixedOnly() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeBreeds => $_getBF(4);
  @$pb.TagNumber(5)
  set includeBreeds($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIncludeBreeds() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeBreeds() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get sex => $_getSZ(5);
  @$pb.TagNumber(6)
  set sex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSex() => $_has(5);
  @$pb.TagNumber(6)
  void clearSex() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.String> get selectedShelters => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get zip => $_getSZ(7);
  @$pb.TagNumber(8)
  set zip($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasZip() => $_has(7);
  @$pb.TagNumber(8)
  void clearZip() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get animalType => $_getSZ(8);
  @$pb.TagNumber(9)
  set animalType($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasAnimalType() => $_has(8);
  @$pb.TagNumber(9)
  void clearAnimalType() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get maxDistance => $_getIZ(9);
  @$pb.TagNumber(10)
  set maxDistance($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasMaxDistance() => $_has(9);
  @$pb.TagNumber(10)
  void clearMaxDistance() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get goodWithChildren => $_getBF(10);
  @$pb.TagNumber(11)
  set goodWithChildren($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasGoodWithChildren() => $_has(10);
  @$pb.TagNumber(11)
  void clearGoodWithChildren() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get goodWithDogs => $_getBF(11);
  @$pb.TagNumber(12)
  set goodWithDogs($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasGoodWithDogs() => $_has(11);
  @$pb.TagNumber(12)
  void clearGoodWithDogs() => clearField(12);

  @$pb.TagNumber(13)
  $core.bool get goodWithCats => $_getBF(12);
  @$pb.TagNumber(13)
  set goodWithCats($core.bool v) { $_setBool(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasGoodWithCats() => $_has(12);
  @$pb.TagNumber(13)
  void clearGoodWithCats() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<$core.String> get coat => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<$core.String> get color => $_getList(14);
}

