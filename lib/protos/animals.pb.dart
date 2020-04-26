///
//  Generated code. Do not modify.
//  source: animals.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class AnimalData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('AnimalData', package: const $pb.PackageName('pawdoption'), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..aOS(2, 'gender')
    ..aOS(3, 'breed')
    ..aOS(4, 'age')
    ..pPS(5, 'imgUrl', protoName: 'imgUrl')
    ..aOS(6, 'id')
    ..aOS(7, 'shelterId', protoName: 'shelterId')
    ..aOS(8, 'apiId', protoName: 'apiId')
    ..aOS(9, 'cityState', protoName: 'cityState')
    ..pPS(10, 'options')
    ..aOS(11, 'size')
    ..aOS(12, 'lastUpdated', protoName: 'lastUpdated')
    ..aOS(13, 'color')
    ..aOS(14, 'thumbUrl', protoName: 'thumbUrl')
    ..aOS(15, 'description')
    ..aOB(16, 'spayedNeutered')
    ..aOB(17, 'houseTrained')
    ..aOB(18, 'specialNeeds')
    ..aOB(19, 'shotsCurrent')
    ..aOB(20, 'goodWithChildren')
    ..aOB(21, 'goodWithCats')
    ..aOB(22, 'goodWithDogs')
    ..a<$fixnum.Int64>(23, 'likedUsec', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  AnimalData._() : super();
  factory AnimalData() => create();
  factory AnimalData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnimalData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  AnimalData clone() => AnimalData()..mergeFromMessage(this);
  AnimalData copyWith(void Function(AnimalData) updates) => super.copyWith((message) => updates(message as AnimalData));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AnimalData create() => AnimalData._();
  AnimalData createEmptyInstance() => create();
  static $pb.PbList<AnimalData> createRepeated() => $pb.PbList<AnimalData>();
  @$core.pragma('dart2js:noInline')
  static AnimalData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnimalData>(create);
  static AnimalData _defaultInstance;

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

