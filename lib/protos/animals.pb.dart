///
//  Generated code. Do not modify.
//  source: animals.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class AnimalData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AnimalData', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'pawdoption'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gender')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'breed')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'age')
    ..pPS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'imgUrl', protoName: 'imgUrl')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'shelterId', protoName: 'shelterId')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'apiId', protoName: 'apiId')
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'cityState', protoName: 'cityState')
    ..pPS(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'options')
    ..aOS(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'size')
    ..aOS(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lastUpdated', protoName: 'lastUpdated')
    ..aOS(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'color')
    ..aOS(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'thumbUrl', protoName: 'thumbUrl')
    ..aOS(15, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'description')
    ..aOB(16, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'spayedNeutered')
    ..aOB(17, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'houseTrained')
    ..aOB(18, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'specialNeeds')
    ..aOB(19, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'shotsCurrent')
    ..aOB(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithChildren')
    ..aOB(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithCats')
    ..aOB(22, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'goodWithDogs')
    ..a<$fixnum.Int64>(23, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'likedUsec', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  AnimalData._() : super();
  factory AnimalData({
    $core.String? name,
    $core.String? gender,
    $core.String? breed,
    $core.String? age,
    $core.Iterable<$core.String>? imgUrl,
    $core.String? id,
    $core.String? shelterId,
    $core.String? apiId,
    $core.String? cityState,
    $core.Iterable<$core.String>? options,
    $core.String? size,
    $core.String? lastUpdated,
    $core.String? color,
    $core.String? thumbUrl,
    $core.String? description,
    $core.bool? spayedNeutered,
    $core.bool? houseTrained,
    $core.bool? specialNeeds,
    $core.bool? shotsCurrent,
    $core.bool? goodWithChildren,
    $core.bool? goodWithCats,
    $core.bool? goodWithDogs,
    $fixnum.Int64? likedUsec,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (gender != null) {
      _result.gender = gender;
    }
    if (breed != null) {
      _result.breed = breed;
    }
    if (age != null) {
      _result.age = age;
    }
    if (imgUrl != null) {
      _result.imgUrl.addAll(imgUrl);
    }
    if (id != null) {
      _result.id = id;
    }
    if (shelterId != null) {
      _result.shelterId = shelterId;
    }
    if (apiId != null) {
      _result.apiId = apiId;
    }
    if (cityState != null) {
      _result.cityState = cityState;
    }
    if (options != null) {
      _result.options.addAll(options);
    }
    if (size != null) {
      _result.size = size;
    }
    if (lastUpdated != null) {
      _result.lastUpdated = lastUpdated;
    }
    if (color != null) {
      _result.color = color;
    }
    if (thumbUrl != null) {
      _result.thumbUrl = thumbUrl;
    }
    if (description != null) {
      _result.description = description;
    }
    if (spayedNeutered != null) {
      _result.spayedNeutered = spayedNeutered;
    }
    if (houseTrained != null) {
      _result.houseTrained = houseTrained;
    }
    if (specialNeeds != null) {
      _result.specialNeeds = specialNeeds;
    }
    if (shotsCurrent != null) {
      _result.shotsCurrent = shotsCurrent;
    }
    if (goodWithChildren != null) {
      _result.goodWithChildren = goodWithChildren;
    }
    if (goodWithCats != null) {
      _result.goodWithCats = goodWithCats;
    }
    if (goodWithDogs != null) {
      _result.goodWithDogs = goodWithDogs;
    }
    if (likedUsec != null) {
      _result.likedUsec = likedUsec;
    }
    return _result;
  }
  factory AnimalData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnimalData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnimalData clone() => AnimalData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnimalData copyWith(void Function(AnimalData) updates) => super.copyWith((message) => updates(message as AnimalData)) as AnimalData; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AnimalData create() => AnimalData._();
  AnimalData createEmptyInstance() => create();
  static $pb.PbList<AnimalData> createRepeated() => $pb.PbList<AnimalData>();
  @$core.pragma('dart2js:noInline')
  static AnimalData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnimalData>(create);
  static AnimalData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get gender => $_getSZ(1);
  @$pb.TagNumber(2)
  set gender($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGender() => $_has(1);
  @$pb.TagNumber(2)
  void clearGender() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get breed => $_getSZ(2);
  @$pb.TagNumber(3)
  set breed($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBreed() => $_has(2);
  @$pb.TagNumber(3)
  void clearBreed() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get age => $_getSZ(3);
  @$pb.TagNumber(4)
  set age($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAge() => $_has(3);
  @$pb.TagNumber(4)
  void clearAge() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get imgUrl => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get id => $_getSZ(5);
  @$pb.TagNumber(6)
  set id($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasId() => $_has(5);
  @$pb.TagNumber(6)
  void clearId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get shelterId => $_getSZ(6);
  @$pb.TagNumber(7)
  set shelterId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasShelterId() => $_has(6);
  @$pb.TagNumber(7)
  void clearShelterId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get apiId => $_getSZ(7);
  @$pb.TagNumber(8)
  set apiId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasApiId() => $_has(7);
  @$pb.TagNumber(8)
  void clearApiId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get cityState => $_getSZ(8);
  @$pb.TagNumber(9)
  set cityState($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCityState() => $_has(8);
  @$pb.TagNumber(9)
  void clearCityState() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.String> get options => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get size => $_getSZ(10);
  @$pb.TagNumber(11)
  set size($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSize() => $_has(10);
  @$pb.TagNumber(11)
  void clearSize() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get lastUpdated => $_getSZ(11);
  @$pb.TagNumber(12)
  set lastUpdated($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasLastUpdated() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastUpdated() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get color => $_getSZ(12);
  @$pb.TagNumber(13)
  set color($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasColor() => $_has(12);
  @$pb.TagNumber(13)
  void clearColor() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get thumbUrl => $_getSZ(13);
  @$pb.TagNumber(14)
  set thumbUrl($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasThumbUrl() => $_has(13);
  @$pb.TagNumber(14)
  void clearThumbUrl() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get description => $_getSZ(14);
  @$pb.TagNumber(15)
  set description($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasDescription() => $_has(14);
  @$pb.TagNumber(15)
  void clearDescription() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get spayedNeutered => $_getBF(15);
  @$pb.TagNumber(16)
  set spayedNeutered($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasSpayedNeutered() => $_has(15);
  @$pb.TagNumber(16)
  void clearSpayedNeutered() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get houseTrained => $_getBF(16);
  @$pb.TagNumber(17)
  set houseTrained($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasHouseTrained() => $_has(16);
  @$pb.TagNumber(17)
  void clearHouseTrained() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get specialNeeds => $_getBF(17);
  @$pb.TagNumber(18)
  set specialNeeds($core.bool v) { $_setBool(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasSpecialNeeds() => $_has(17);
  @$pb.TagNumber(18)
  void clearSpecialNeeds() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get shotsCurrent => $_getBF(18);
  @$pb.TagNumber(19)
  set shotsCurrent($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasShotsCurrent() => $_has(18);
  @$pb.TagNumber(19)
  void clearShotsCurrent() => clearField(19);

  @$pb.TagNumber(20)
  $core.bool get goodWithChildren => $_getBF(19);
  @$pb.TagNumber(20)
  set goodWithChildren($core.bool v) { $_setBool(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasGoodWithChildren() => $_has(19);
  @$pb.TagNumber(20)
  void clearGoodWithChildren() => clearField(20);

  @$pb.TagNumber(21)
  $core.bool get goodWithCats => $_getBF(20);
  @$pb.TagNumber(21)
  set goodWithCats($core.bool v) { $_setBool(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasGoodWithCats() => $_has(20);
  @$pb.TagNumber(21)
  void clearGoodWithCats() => clearField(21);

  @$pb.TagNumber(22)
  $core.bool get goodWithDogs => $_getBF(21);
  @$pb.TagNumber(22)
  set goodWithDogs($core.bool v) { $_setBool(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasGoodWithDogs() => $_has(21);
  @$pb.TagNumber(22)
  void clearGoodWithDogs() => clearField(22);

  @$pb.TagNumber(23)
  $fixnum.Int64 get likedUsec => $_getI64(22);
  @$pb.TagNumber(23)
  set likedUsec($fixnum.Int64 v) { $_setInt64(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasLikedUsec() => $_has(22);
  @$pb.TagNumber(23)
  void clearLikedUsec() => clearField(23);
}

