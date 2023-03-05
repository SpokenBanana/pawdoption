///
//  Generated code. Do not modify.
//  source: pet_search_options.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PetSearchOptions extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PetSearchOptions', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'pawdoption'), createEmptyInstance: create)
    ..pPS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'breeds')
    ..pPS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ages')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sizes')
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fixedOnly')
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'includeBreeds')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sex')
    ..pPS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selectedShelters')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'zip')
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'animalType')
    ..a<$core.int>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'maxDistance', $pb.PbFieldType.O3)
    ..aOB(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithChildren')
    ..aOB(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithDogs')
    ..aOB(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithCats')
    ..pPS(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'coat')
    ..pPS(15, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'color')
    ..hasRequiredFields = false
  ;

  PetSearchOptions._() : super();
  factory PetSearchOptions({
    $core.Iterable<$core.String>? breeds,
    $core.Iterable<$core.String>? ages,
    $core.Iterable<$core.String>? sizes,
    $core.bool? fixedOnly,
    $core.bool? includeBreeds,
    $core.String? sex,
    $core.Iterable<$core.String>? selectedShelters,
    $core.String? zip,
    $core.String? animalType,
    $core.int? maxDistance,
    $core.bool? goodWithChildren,
    $core.bool? goodWithDogs,
    $core.bool? goodWithCats,
    $core.Iterable<$core.String>? coat,
    $core.Iterable<$core.String>? color,
  }) {
    final _result = create();
    if (breeds != null) {
      _result.breeds.addAll(breeds);
    }
    if (ages != null) {
      _result.ages.addAll(ages);
    }
    if (sizes != null) {
      _result.sizes.addAll(sizes);
    }
    if (fixedOnly != null) {
      _result.fixedOnly = fixedOnly;
    }
    if (includeBreeds != null) {
      _result.includeBreeds = includeBreeds;
    }
    if (sex != null) {
      _result.sex = sex;
    }
    if (selectedShelters != null) {
      _result.selectedShelters.addAll(selectedShelters);
    }
    if (zip != null) {
      _result.zip = zip;
    }
    if (animalType != null) {
      _result.animalType = animalType;
    }
    if (maxDistance != null) {
      _result.maxDistance = maxDistance;
    }
    if (goodWithChildren != null) {
      _result.goodWithChildren = goodWithChildren;
    }
    if (goodWithDogs != null) {
      _result.goodWithDogs = goodWithDogs;
    }
    if (goodWithCats != null) {
      _result.goodWithCats = goodWithCats;
    }
    if (coat != null) {
      _result.coat.addAll(coat);
    }
    if (color != null) {
      _result.color.addAll(color);
    }
    return _result;
  }
  factory PetSearchOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PetSearchOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PetSearchOptions clone() => PetSearchOptions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PetSearchOptions copyWith(void Function(PetSearchOptions) updates) => super.copyWith((message) => updates(message as PetSearchOptions)) as PetSearchOptions; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PetSearchOptions create() => PetSearchOptions._();
  PetSearchOptions createEmptyInstance() => create();
  static $pb.PbList<PetSearchOptions> createRepeated() => $pb.PbList<PetSearchOptions>();
  @$core.pragma('dart2js:noInline')
  static PetSearchOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PetSearchOptions>(create);
  static PetSearchOptions? _defaultInstance;

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

