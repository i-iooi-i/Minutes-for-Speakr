// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tag {

 int get id; String get name; String? get color;@JsonKey(name: 'custom_prompt') String? get customPrompt;@JsonKey(name: 'default_language') String? get defaultLanguage;@JsonKey(name: 'default_min_speakers') int? get defaultMinSpeakers;@JsonKey(name: 'default_max_speakers') int? get defaultMaxSpeakers;
/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCopyWith<Tag> get copyWith => _$TagCopyWithImpl<Tag>(this as Tag, _$identity);

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.customPrompt, customPrompt) || other.customPrompt == customPrompt)&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.defaultMinSpeakers, defaultMinSpeakers) || other.defaultMinSpeakers == defaultMinSpeakers)&&(identical(other.defaultMaxSpeakers, defaultMaxSpeakers) || other.defaultMaxSpeakers == defaultMaxSpeakers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,customPrompt,defaultLanguage,defaultMinSpeakers,defaultMaxSpeakers);

@override
String toString() {
  return 'Tag(id: $id, name: $name, color: $color, customPrompt: $customPrompt, defaultLanguage: $defaultLanguage, defaultMinSpeakers: $defaultMinSpeakers, defaultMaxSpeakers: $defaultMaxSpeakers)';
}


}

/// @nodoc
abstract mixin class $TagCopyWith<$Res>  {
  factory $TagCopyWith(Tag value, $Res Function(Tag) _then) = _$TagCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? color,@JsonKey(name: 'custom_prompt') String? customPrompt,@JsonKey(name: 'default_language') String? defaultLanguage,@JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,@JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers
});




}
/// @nodoc
class _$TagCopyWithImpl<$Res>
    implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._self, this._then);

  final Tag _self;
  final $Res Function(Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? customPrompt = freezed,Object? defaultLanguage = freezed,Object? defaultMinSpeakers = freezed,Object? defaultMaxSpeakers = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,customPrompt: freezed == customPrompt ? _self.customPrompt : customPrompt // ignore: cast_nullable_to_non_nullable
as String?,defaultLanguage: freezed == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as String?,defaultMinSpeakers: freezed == defaultMinSpeakers ? _self.defaultMinSpeakers : defaultMinSpeakers // ignore: cast_nullable_to_non_nullable
as int?,defaultMaxSpeakers: freezed == defaultMaxSpeakers ? _self.defaultMaxSpeakers : defaultMaxSpeakers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tag].
extension TagPatterns on Tag {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tag value)  $default,){
final _that = this;
switch (_that) {
case _Tag():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tag value)?  $default,){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? color, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'default_language')  String? defaultLanguage, @JsonKey(name: 'default_min_speakers')  int? defaultMinSpeakers, @JsonKey(name: 'default_max_speakers')  int? defaultMaxSpeakers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.customPrompt,_that.defaultLanguage,_that.defaultMinSpeakers,_that.defaultMaxSpeakers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? color, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'default_language')  String? defaultLanguage, @JsonKey(name: 'default_min_speakers')  int? defaultMinSpeakers, @JsonKey(name: 'default_max_speakers')  int? defaultMaxSpeakers)  $default,) {final _that = this;
switch (_that) {
case _Tag():
return $default(_that.id,_that.name,_that.color,_that.customPrompt,_that.defaultLanguage,_that.defaultMinSpeakers,_that.defaultMaxSpeakers);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? color, @JsonKey(name: 'custom_prompt')  String? customPrompt, @JsonKey(name: 'default_language')  String? defaultLanguage, @JsonKey(name: 'default_min_speakers')  int? defaultMinSpeakers, @JsonKey(name: 'default_max_speakers')  int? defaultMaxSpeakers)?  $default,) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.customPrompt,_that.defaultLanguage,_that.defaultMinSpeakers,_that.defaultMaxSpeakers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tag implements Tag {
  const _Tag({required this.id, required this.name, this.color, @JsonKey(name: 'custom_prompt') this.customPrompt, @JsonKey(name: 'default_language') this.defaultLanguage, @JsonKey(name: 'default_min_speakers') this.defaultMinSpeakers, @JsonKey(name: 'default_max_speakers') this.defaultMaxSpeakers});
  factory _Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? color;
@override@JsonKey(name: 'custom_prompt') final  String? customPrompt;
@override@JsonKey(name: 'default_language') final  String? defaultLanguage;
@override@JsonKey(name: 'default_min_speakers') final  int? defaultMinSpeakers;
@override@JsonKey(name: 'default_max_speakers') final  int? defaultMaxSpeakers;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCopyWith<_Tag> get copyWith => __$TagCopyWithImpl<_Tag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.customPrompt, customPrompt) || other.customPrompt == customPrompt)&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.defaultMinSpeakers, defaultMinSpeakers) || other.defaultMinSpeakers == defaultMinSpeakers)&&(identical(other.defaultMaxSpeakers, defaultMaxSpeakers) || other.defaultMaxSpeakers == defaultMaxSpeakers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,customPrompt,defaultLanguage,defaultMinSpeakers,defaultMaxSpeakers);

@override
String toString() {
  return 'Tag(id: $id, name: $name, color: $color, customPrompt: $customPrompt, defaultLanguage: $defaultLanguage, defaultMinSpeakers: $defaultMinSpeakers, defaultMaxSpeakers: $defaultMaxSpeakers)';
}


}

/// @nodoc
abstract mixin class _$TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$TagCopyWith(_Tag value, $Res Function(_Tag) _then) = __$TagCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? color,@JsonKey(name: 'custom_prompt') String? customPrompt,@JsonKey(name: 'default_language') String? defaultLanguage,@JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,@JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers
});




}
/// @nodoc
class __$TagCopyWithImpl<$Res>
    implements _$TagCopyWith<$Res> {
  __$TagCopyWithImpl(this._self, this._then);

  final _Tag _self;
  final $Res Function(_Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? customPrompt = freezed,Object? defaultLanguage = freezed,Object? defaultMinSpeakers = freezed,Object? defaultMaxSpeakers = freezed,}) {
  return _then(_Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,customPrompt: freezed == customPrompt ? _self.customPrompt : customPrompt // ignore: cast_nullable_to_non_nullable
as String?,defaultLanguage: freezed == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as String?,defaultMinSpeakers: freezed == defaultMinSpeakers ? _self.defaultMinSpeakers : defaultMinSpeakers // ignore: cast_nullable_to_non_nullable
as int?,defaultMaxSpeakers: freezed == defaultMaxSpeakers ? _self.defaultMaxSpeakers : defaultMaxSpeakers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Folder {

 int get id; String get name; String? get color;@JsonKey(name: 'recording_count') int? get recordingCount;
/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderCopyWith<Folder> get copyWith => _$FolderCopyWithImpl<Folder>(this as Folder, _$identity);

  /// Serializes this Folder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Folder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.recordingCount, recordingCount) || other.recordingCount == recordingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,recordingCount);

@override
String toString() {
  return 'Folder(id: $id, name: $name, color: $color, recordingCount: $recordingCount)';
}


}

/// @nodoc
abstract mixin class $FolderCopyWith<$Res>  {
  factory $FolderCopyWith(Folder value, $Res Function(Folder) _then) = _$FolderCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? color,@JsonKey(name: 'recording_count') int? recordingCount
});




}
/// @nodoc
class _$FolderCopyWithImpl<$Res>
    implements $FolderCopyWith<$Res> {
  _$FolderCopyWithImpl(this._self, this._then);

  final Folder _self;
  final $Res Function(Folder) _then;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? recordingCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,recordingCount: freezed == recordingCount ? _self.recordingCount : recordingCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Folder].
extension FolderPatterns on Folder {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Folder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Folder value)  $default,){
final _that = this;
switch (_that) {
case _Folder():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Folder value)?  $default,){
final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? color, @JsonKey(name: 'recording_count')  int? recordingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.recordingCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? color, @JsonKey(name: 'recording_count')  int? recordingCount)  $default,) {final _that = this;
switch (_that) {
case _Folder():
return $default(_that.id,_that.name,_that.color,_that.recordingCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? color, @JsonKey(name: 'recording_count')  int? recordingCount)?  $default,) {final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.recordingCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Folder implements Folder {
  const _Folder({required this.id, required this.name, this.color, @JsonKey(name: 'recording_count') this.recordingCount});
  factory _Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? color;
@override@JsonKey(name: 'recording_count') final  int? recordingCount;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderCopyWith<_Folder> get copyWith => __$FolderCopyWithImpl<_Folder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Folder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.recordingCount, recordingCount) || other.recordingCount == recordingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,recordingCount);

@override
String toString() {
  return 'Folder(id: $id, name: $name, color: $color, recordingCount: $recordingCount)';
}


}

/// @nodoc
abstract mixin class _$FolderCopyWith<$Res> implements $FolderCopyWith<$Res> {
  factory _$FolderCopyWith(_Folder value, $Res Function(_Folder) _then) = __$FolderCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? color,@JsonKey(name: 'recording_count') int? recordingCount
});




}
/// @nodoc
class __$FolderCopyWithImpl<$Res>
    implements _$FolderCopyWith<$Res> {
  __$FolderCopyWithImpl(this._self, this._then);

  final _Folder _self;
  final $Res Function(_Folder) _then;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? recordingCount = freezed,}) {
  return _then(_Folder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,recordingCount: freezed == recordingCount ? _self.recordingCount : recordingCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Speaker {

 int get id; String get name;@JsonKey(name: 'has_voice_profile') bool get hasVoiceProfile;@JsonKey(name: 'use_count') int get useCount;@JsonKey(name: 'last_used', fromJson: _parseFlexibleDate) DateTime? get lastUsed;
/// Create a copy of Speaker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeakerCopyWith<Speaker> get copyWith => _$SpeakerCopyWithImpl<Speaker>(this as Speaker, _$identity);

  /// Serializes this Speaker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Speaker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hasVoiceProfile, hasVoiceProfile) || other.hasVoiceProfile == hasVoiceProfile)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,hasVoiceProfile,useCount,lastUsed);

@override
String toString() {
  return 'Speaker(id: $id, name: $name, hasVoiceProfile: $hasVoiceProfile, useCount: $useCount, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class $SpeakerCopyWith<$Res>  {
  factory $SpeakerCopyWith(Speaker value, $Res Function(Speaker) _then) = _$SpeakerCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'has_voice_profile') bool hasVoiceProfile,@JsonKey(name: 'use_count') int useCount,@JsonKey(name: 'last_used', fromJson: _parseFlexibleDate) DateTime? lastUsed
});




}
/// @nodoc
class _$SpeakerCopyWithImpl<$Res>
    implements $SpeakerCopyWith<$Res> {
  _$SpeakerCopyWithImpl(this._self, this._then);

  final Speaker _self;
  final $Res Function(Speaker) _then;

/// Create a copy of Speaker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? hasVoiceProfile = null,Object? useCount = null,Object? lastUsed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hasVoiceProfile: null == hasVoiceProfile ? _self.hasVoiceProfile : hasVoiceProfile // ignore: cast_nullable_to_non_nullable
as bool,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Speaker].
extension SpeakerPatterns on Speaker {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Speaker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Speaker() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Speaker value)  $default,){
final _that = this;
switch (_that) {
case _Speaker():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Speaker value)?  $default,){
final _that = this;
switch (_that) {
case _Speaker() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'has_voice_profile')  bool hasVoiceProfile, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'last_used', fromJson: _parseFlexibleDate)  DateTime? lastUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Speaker() when $default != null:
return $default(_that.id,_that.name,_that.hasVoiceProfile,_that.useCount,_that.lastUsed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'has_voice_profile')  bool hasVoiceProfile, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'last_used', fromJson: _parseFlexibleDate)  DateTime? lastUsed)  $default,) {final _that = this;
switch (_that) {
case _Speaker():
return $default(_that.id,_that.name,_that.hasVoiceProfile,_that.useCount,_that.lastUsed);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'has_voice_profile')  bool hasVoiceProfile, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'last_used', fromJson: _parseFlexibleDate)  DateTime? lastUsed)?  $default,) {final _that = this;
switch (_that) {
case _Speaker() when $default != null:
return $default(_that.id,_that.name,_that.hasVoiceProfile,_that.useCount,_that.lastUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Speaker implements Speaker {
  const _Speaker({required this.id, required this.name, @JsonKey(name: 'has_voice_profile') this.hasVoiceProfile = false, @JsonKey(name: 'use_count') this.useCount = 0, @JsonKey(name: 'last_used', fromJson: _parseFlexibleDate) this.lastUsed});
  factory _Speaker.fromJson(Map<String, dynamic> json) => _$SpeakerFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'has_voice_profile') final  bool hasVoiceProfile;
@override@JsonKey(name: 'use_count') final  int useCount;
@override@JsonKey(name: 'last_used', fromJson: _parseFlexibleDate) final  DateTime? lastUsed;

/// Create a copy of Speaker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeakerCopyWith<_Speaker> get copyWith => __$SpeakerCopyWithImpl<_Speaker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpeakerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Speaker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hasVoiceProfile, hasVoiceProfile) || other.hasVoiceProfile == hasVoiceProfile)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,hasVoiceProfile,useCount,lastUsed);

@override
String toString() {
  return 'Speaker(id: $id, name: $name, hasVoiceProfile: $hasVoiceProfile, useCount: $useCount, lastUsed: $lastUsed)';
}


}

/// @nodoc
abstract mixin class _$SpeakerCopyWith<$Res> implements $SpeakerCopyWith<$Res> {
  factory _$SpeakerCopyWith(_Speaker value, $Res Function(_Speaker) _then) = __$SpeakerCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'has_voice_profile') bool hasVoiceProfile,@JsonKey(name: 'use_count') int useCount,@JsonKey(name: 'last_used', fromJson: _parseFlexibleDate) DateTime? lastUsed
});




}
/// @nodoc
class __$SpeakerCopyWithImpl<$Res>
    implements _$SpeakerCopyWith<$Res> {
  __$SpeakerCopyWithImpl(this._self, this._then);

  final _Speaker _self;
  final $Res Function(_Speaker) _then;

/// Create a copy of Speaker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? hasVoiceProfile = null,Object? useCount = null,Object? lastUsed = freezed,}) {
  return _then(_Speaker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hasVoiceProfile: null == hasVoiceProfile ? _self.hasVoiceProfile : hasVoiceProfile // ignore: cast_nullable_to_non_nullable
as bool,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SpeakerSuggestion {

@JsonKey(name: 'speaker_id') int get speakerId; String get name; double get confidence; double get similarity;@JsonKey(name: 'embedding_count') int get embeddingCount;
/// Create a copy of SpeakerSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeakerSuggestionCopyWith<SpeakerSuggestion> get copyWith => _$SpeakerSuggestionCopyWithImpl<SpeakerSuggestion>(this as SpeakerSuggestion, _$identity);

  /// Serializes this SpeakerSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeakerSuggestion&&(identical(other.speakerId, speakerId) || other.speakerId == speakerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.similarity, similarity) || other.similarity == similarity)&&(identical(other.embeddingCount, embeddingCount) || other.embeddingCount == embeddingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,speakerId,name,confidence,similarity,embeddingCount);

@override
String toString() {
  return 'SpeakerSuggestion(speakerId: $speakerId, name: $name, confidence: $confidence, similarity: $similarity, embeddingCount: $embeddingCount)';
}


}

/// @nodoc
abstract mixin class $SpeakerSuggestionCopyWith<$Res>  {
  factory $SpeakerSuggestionCopyWith(SpeakerSuggestion value, $Res Function(SpeakerSuggestion) _then) = _$SpeakerSuggestionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'speaker_id') int speakerId, String name, double confidence, double similarity,@JsonKey(name: 'embedding_count') int embeddingCount
});




}
/// @nodoc
class _$SpeakerSuggestionCopyWithImpl<$Res>
    implements $SpeakerSuggestionCopyWith<$Res> {
  _$SpeakerSuggestionCopyWithImpl(this._self, this._then);

  final SpeakerSuggestion _self;
  final $Res Function(SpeakerSuggestion) _then;

/// Create a copy of SpeakerSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speakerId = null,Object? name = null,Object? confidence = null,Object? similarity = null,Object? embeddingCount = null,}) {
  return _then(_self.copyWith(
speakerId: null == speakerId ? _self.speakerId : speakerId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,embeddingCount: null == embeddingCount ? _self.embeddingCount : embeddingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SpeakerSuggestion].
extension SpeakerSuggestionPatterns on SpeakerSuggestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpeakerSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpeakerSuggestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpeakerSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _SpeakerSuggestion():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpeakerSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _SpeakerSuggestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'speaker_id')  int speakerId,  String name,  double confidence,  double similarity, @JsonKey(name: 'embedding_count')  int embeddingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpeakerSuggestion() when $default != null:
return $default(_that.speakerId,_that.name,_that.confidence,_that.similarity,_that.embeddingCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'speaker_id')  int speakerId,  String name,  double confidence,  double similarity, @JsonKey(name: 'embedding_count')  int embeddingCount)  $default,) {final _that = this;
switch (_that) {
case _SpeakerSuggestion():
return $default(_that.speakerId,_that.name,_that.confidence,_that.similarity,_that.embeddingCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'speaker_id')  int speakerId,  String name,  double confidence,  double similarity, @JsonKey(name: 'embedding_count')  int embeddingCount)?  $default,) {final _that = this;
switch (_that) {
case _SpeakerSuggestion() when $default != null:
return $default(_that.speakerId,_that.name,_that.confidence,_that.similarity,_that.embeddingCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpeakerSuggestion implements SpeakerSuggestion {
  const _SpeakerSuggestion({@JsonKey(name: 'speaker_id') required this.speakerId, required this.name, this.confidence = 0.0, this.similarity = 0.0, @JsonKey(name: 'embedding_count') this.embeddingCount = 0});
  factory _SpeakerSuggestion.fromJson(Map<String, dynamic> json) => _$SpeakerSuggestionFromJson(json);

@override@JsonKey(name: 'speaker_id') final  int speakerId;
@override final  String name;
@override@JsonKey() final  double confidence;
@override@JsonKey() final  double similarity;
@override@JsonKey(name: 'embedding_count') final  int embeddingCount;

/// Create a copy of SpeakerSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeakerSuggestionCopyWith<_SpeakerSuggestion> get copyWith => __$SpeakerSuggestionCopyWithImpl<_SpeakerSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpeakerSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpeakerSuggestion&&(identical(other.speakerId, speakerId) || other.speakerId == speakerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.similarity, similarity) || other.similarity == similarity)&&(identical(other.embeddingCount, embeddingCount) || other.embeddingCount == embeddingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,speakerId,name,confidence,similarity,embeddingCount);

@override
String toString() {
  return 'SpeakerSuggestion(speakerId: $speakerId, name: $name, confidence: $confidence, similarity: $similarity, embeddingCount: $embeddingCount)';
}


}

/// @nodoc
abstract mixin class _$SpeakerSuggestionCopyWith<$Res> implements $SpeakerSuggestionCopyWith<$Res> {
  factory _$SpeakerSuggestionCopyWith(_SpeakerSuggestion value, $Res Function(_SpeakerSuggestion) _then) = __$SpeakerSuggestionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'speaker_id') int speakerId, String name, double confidence, double similarity,@JsonKey(name: 'embedding_count') int embeddingCount
});




}
/// @nodoc
class __$SpeakerSuggestionCopyWithImpl<$Res>
    implements _$SpeakerSuggestionCopyWith<$Res> {
  __$SpeakerSuggestionCopyWithImpl(this._self, this._then);

  final _SpeakerSuggestion _self;
  final $Res Function(_SpeakerSuggestion) _then;

/// Create a copy of SpeakerSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speakerId = null,Object? name = null,Object? confidence = null,Object? similarity = null,Object? embeddingCount = null,}) {
  return _then(_SpeakerSuggestion(
speakerId: null == speakerId ? _self.speakerId : speakerId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,embeddingCount: null == embeddingCount ? _self.embeddingCount : embeddingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Recording {

 int get id; String? get title;@JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate) DateTime? get meetingDate;@JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) DateTime? get createdAt; String? get participants;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'is_highlighted') bool get isHighlighted;@JsonKey(name: 'is_archived') bool get isArchived;@JsonKey(name: 'is_inbox') bool get isInbox;@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus get status; List<Tag> get tags;@JsonKey(name: 'folder_id') int? get folderId; Folder? get folder;// Returned by the v1 list endpoint.
@JsonKey(name: 'audio_available') bool? get audioAvailable;@JsonKey(name: 'error_message') String? get errorMessage;@JsonKey(name: 'has_summary') bool? get hasSummary;@JsonKey(name: 'has_transcription') bool? get hasTranscription;@JsonKey(name: 'original_filename') String? get originalFilename;// Optional rich fields returned by the unofficial /api/recordings/{id}.
 String? get summary; String? get notes; String? get transcription;@JsonKey(name: 'audio_duration') double? get audioDuration;// Optional transcription parameters — present on the unofficial detail
// endpoint when set; absent otherwise. Used to pre-fill the reprocess
// transcription dialog.
@JsonKey(name: 'transcription_model') String? get transcriptionModel; String? get language;@JsonKey(name: 'min_speakers') int? get minSpeakers;@JsonKey(name: 'max_speakers') int? get maxSpeakers; String? get hotwords;@JsonKey(name: 'initial_prompt') String? get initialPrompt;
/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingCopyWith<Recording> get copyWith => _$RecordingCopyWithImpl<Recording>(this as Recording, _$identity);

  /// Serializes this Recording to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recording&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.meetingDate, meetingDate) || other.meetingDate == meetingDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.isHighlighted, isHighlighted) || other.isHighlighted == isHighlighted)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isInbox, isInbox) || other.isInbox == isInbox)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.folder, folder) || other.folder == folder)&&(identical(other.audioAvailable, audioAvailable) || other.audioAvailable == audioAvailable)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasSummary, hasSummary) || other.hasSummary == hasSummary)&&(identical(other.hasTranscription, hasTranscription) || other.hasTranscription == hasTranscription)&&(identical(other.originalFilename, originalFilename) || other.originalFilename == originalFilename)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.transcription, transcription) || other.transcription == transcription)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&(identical(other.transcriptionModel, transcriptionModel) || other.transcriptionModel == transcriptionModel)&&(identical(other.language, language) || other.language == language)&&(identical(other.minSpeakers, minSpeakers) || other.minSpeakers == minSpeakers)&&(identical(other.maxSpeakers, maxSpeakers) || other.maxSpeakers == maxSpeakers)&&(identical(other.hotwords, hotwords) || other.hotwords == hotwords)&&(identical(other.initialPrompt, initialPrompt) || other.initialPrompt == initialPrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,meetingDate,createdAt,participants,fileSize,isHighlighted,isArchived,isInbox,status,const DeepCollectionEquality().hash(tags),folderId,folder,audioAvailable,errorMessage,hasSummary,hasTranscription,originalFilename,summary,notes,transcription,audioDuration,transcriptionModel,language,minSpeakers,maxSpeakers,hotwords,initialPrompt]);

@override
String toString() {
  return 'Recording(id: $id, title: $title, meetingDate: $meetingDate, createdAt: $createdAt, participants: $participants, fileSize: $fileSize, isHighlighted: $isHighlighted, isArchived: $isArchived, isInbox: $isInbox, status: $status, tags: $tags, folderId: $folderId, folder: $folder, audioAvailable: $audioAvailable, errorMessage: $errorMessage, hasSummary: $hasSummary, hasTranscription: $hasTranscription, originalFilename: $originalFilename, summary: $summary, notes: $notes, transcription: $transcription, audioDuration: $audioDuration, transcriptionModel: $transcriptionModel, language: $language, minSpeakers: $minSpeakers, maxSpeakers: $maxSpeakers, hotwords: $hotwords, initialPrompt: $initialPrompt)';
}


}

/// @nodoc
abstract mixin class $RecordingCopyWith<$Res>  {
  factory $RecordingCopyWith(Recording value, $Res Function(Recording) _then) = _$RecordingCopyWithImpl;
@useResult
$Res call({
 int id, String? title,@JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate) DateTime? meetingDate,@JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) DateTime? createdAt, String? participants,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'is_highlighted') bool isHighlighted,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_inbox') bool isInbox,@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status, List<Tag> tags,@JsonKey(name: 'folder_id') int? folderId, Folder? folder,@JsonKey(name: 'audio_available') bool? audioAvailable,@JsonKey(name: 'error_message') String? errorMessage,@JsonKey(name: 'has_summary') bool? hasSummary,@JsonKey(name: 'has_transcription') bool? hasTranscription,@JsonKey(name: 'original_filename') String? originalFilename, String? summary, String? notes, String? transcription,@JsonKey(name: 'audio_duration') double? audioDuration,@JsonKey(name: 'transcription_model') String? transcriptionModel, String? language,@JsonKey(name: 'min_speakers') int? minSpeakers,@JsonKey(name: 'max_speakers') int? maxSpeakers, String? hotwords,@JsonKey(name: 'initial_prompt') String? initialPrompt
});


$FolderCopyWith<$Res>? get folder;

}
/// @nodoc
class _$RecordingCopyWithImpl<$Res>
    implements $RecordingCopyWith<$Res> {
  _$RecordingCopyWithImpl(this._self, this._then);

  final Recording _self;
  final $Res Function(Recording) _then;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? meetingDate = freezed,Object? createdAt = freezed,Object? participants = freezed,Object? fileSize = freezed,Object? isHighlighted = null,Object? isArchived = null,Object? isInbox = null,Object? status = null,Object? tags = null,Object? folderId = freezed,Object? folder = freezed,Object? audioAvailable = freezed,Object? errorMessage = freezed,Object? hasSummary = freezed,Object? hasTranscription = freezed,Object? originalFilename = freezed,Object? summary = freezed,Object? notes = freezed,Object? transcription = freezed,Object? audioDuration = freezed,Object? transcriptionModel = freezed,Object? language = freezed,Object? minSpeakers = freezed,Object? maxSpeakers = freezed,Object? hotwords = freezed,Object? initialPrompt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,meetingDate: freezed == meetingDate ? _self.meetingDate : meetingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,participants: freezed == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,isHighlighted: null == isHighlighted ? _self.isHighlighted : isHighlighted // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isInbox: null == isInbox ? _self.isInbox : isInbox // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as int?,folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as Folder?,audioAvailable: freezed == audioAvailable ? _self.audioAvailable : audioAvailable // ignore: cast_nullable_to_non_nullable
as bool?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasSummary: freezed == hasSummary ? _self.hasSummary : hasSummary // ignore: cast_nullable_to_non_nullable
as bool?,hasTranscription: freezed == hasTranscription ? _self.hasTranscription : hasTranscription // ignore: cast_nullable_to_non_nullable
as bool?,originalFilename: freezed == originalFilename ? _self.originalFilename : originalFilename // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,transcription: freezed == transcription ? _self.transcription : transcription // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as double?,transcriptionModel: freezed == transcriptionModel ? _self.transcriptionModel : transcriptionModel // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,minSpeakers: freezed == minSpeakers ? _self.minSpeakers : minSpeakers // ignore: cast_nullable_to_non_nullable
as int?,maxSpeakers: freezed == maxSpeakers ? _self.maxSpeakers : maxSpeakers // ignore: cast_nullable_to_non_nullable
as int?,hotwords: freezed == hotwords ? _self.hotwords : hotwords // ignore: cast_nullable_to_non_nullable
as String?,initialPrompt: freezed == initialPrompt ? _self.initialPrompt : initialPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FolderCopyWith<$Res>? get folder {
    if (_self.folder == null) {
    return null;
  }

  return $FolderCopyWith<$Res>(_self.folder!, (value) {
    return _then(_self.copyWith(folder: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recording].
extension RecordingPatterns on Recording {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recording value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recording value)  $default,){
final _that = this;
switch (_that) {
case _Recording():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recording value)?  $default,){
final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? title, @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)  DateTime? meetingDate, @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)  DateTime? createdAt,  String? participants, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'is_highlighted')  bool isHighlighted, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_inbox')  bool isInbox, @JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status,  List<Tag> tags, @JsonKey(name: 'folder_id')  int? folderId,  Folder? folder, @JsonKey(name: 'audio_available')  bool? audioAvailable, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'has_summary')  bool? hasSummary, @JsonKey(name: 'has_transcription')  bool? hasTranscription, @JsonKey(name: 'original_filename')  String? originalFilename,  String? summary,  String? notes,  String? transcription, @JsonKey(name: 'audio_duration')  double? audioDuration, @JsonKey(name: 'transcription_model')  String? transcriptionModel,  String? language, @JsonKey(name: 'min_speakers')  int? minSpeakers, @JsonKey(name: 'max_speakers')  int? maxSpeakers,  String? hotwords, @JsonKey(name: 'initial_prompt')  String? initialPrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that.id,_that.title,_that.meetingDate,_that.createdAt,_that.participants,_that.fileSize,_that.isHighlighted,_that.isArchived,_that.isInbox,_that.status,_that.tags,_that.folderId,_that.folder,_that.audioAvailable,_that.errorMessage,_that.hasSummary,_that.hasTranscription,_that.originalFilename,_that.summary,_that.notes,_that.transcription,_that.audioDuration,_that.transcriptionModel,_that.language,_that.minSpeakers,_that.maxSpeakers,_that.hotwords,_that.initialPrompt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? title, @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)  DateTime? meetingDate, @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)  DateTime? createdAt,  String? participants, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'is_highlighted')  bool isHighlighted, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_inbox')  bool isInbox, @JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status,  List<Tag> tags, @JsonKey(name: 'folder_id')  int? folderId,  Folder? folder, @JsonKey(name: 'audio_available')  bool? audioAvailable, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'has_summary')  bool? hasSummary, @JsonKey(name: 'has_transcription')  bool? hasTranscription, @JsonKey(name: 'original_filename')  String? originalFilename,  String? summary,  String? notes,  String? transcription, @JsonKey(name: 'audio_duration')  double? audioDuration, @JsonKey(name: 'transcription_model')  String? transcriptionModel,  String? language, @JsonKey(name: 'min_speakers')  int? minSpeakers, @JsonKey(name: 'max_speakers')  int? maxSpeakers,  String? hotwords, @JsonKey(name: 'initial_prompt')  String? initialPrompt)  $default,) {final _that = this;
switch (_that) {
case _Recording():
return $default(_that.id,_that.title,_that.meetingDate,_that.createdAt,_that.participants,_that.fileSize,_that.isHighlighted,_that.isArchived,_that.isInbox,_that.status,_that.tags,_that.folderId,_that.folder,_that.audioAvailable,_that.errorMessage,_that.hasSummary,_that.hasTranscription,_that.originalFilename,_that.summary,_that.notes,_that.transcription,_that.audioDuration,_that.transcriptionModel,_that.language,_that.minSpeakers,_that.maxSpeakers,_that.hotwords,_that.initialPrompt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? title, @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)  DateTime? meetingDate, @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)  DateTime? createdAt,  String? participants, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'is_highlighted')  bool isHighlighted, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_inbox')  bool isInbox, @JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status,  List<Tag> tags, @JsonKey(name: 'folder_id')  int? folderId,  Folder? folder, @JsonKey(name: 'audio_available')  bool? audioAvailable, @JsonKey(name: 'error_message')  String? errorMessage, @JsonKey(name: 'has_summary')  bool? hasSummary, @JsonKey(name: 'has_transcription')  bool? hasTranscription, @JsonKey(name: 'original_filename')  String? originalFilename,  String? summary,  String? notes,  String? transcription, @JsonKey(name: 'audio_duration')  double? audioDuration, @JsonKey(name: 'transcription_model')  String? transcriptionModel,  String? language, @JsonKey(name: 'min_speakers')  int? minSpeakers, @JsonKey(name: 'max_speakers')  int? maxSpeakers,  String? hotwords, @JsonKey(name: 'initial_prompt')  String? initialPrompt)?  $default,) {final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that.id,_that.title,_that.meetingDate,_that.createdAt,_that.participants,_that.fileSize,_that.isHighlighted,_that.isArchived,_that.isInbox,_that.status,_that.tags,_that.folderId,_that.folder,_that.audioAvailable,_that.errorMessage,_that.hasSummary,_that.hasTranscription,_that.originalFilename,_that.summary,_that.notes,_that.transcription,_that.audioDuration,_that.transcriptionModel,_that.language,_that.minSpeakers,_that.maxSpeakers,_that.hotwords,_that.initialPrompt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recording implements Recording {
  const _Recording({required this.id, this.title, @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate) this.meetingDate, @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) this.createdAt, this.participants, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'is_highlighted') this.isHighlighted = false, @JsonKey(name: 'is_archived') this.isArchived = false, @JsonKey(name: 'is_inbox') this.isInbox = false, @JsonKey(fromJson: _parseRecordingStatus) this.status = RecordingStatus.completed, final  List<Tag> tags = const <Tag>[], @JsonKey(name: 'folder_id') this.folderId, this.folder, @JsonKey(name: 'audio_available') this.audioAvailable, @JsonKey(name: 'error_message') this.errorMessage, @JsonKey(name: 'has_summary') this.hasSummary, @JsonKey(name: 'has_transcription') this.hasTranscription, @JsonKey(name: 'original_filename') this.originalFilename, this.summary, this.notes, this.transcription, @JsonKey(name: 'audio_duration') this.audioDuration, @JsonKey(name: 'transcription_model') this.transcriptionModel, this.language, @JsonKey(name: 'min_speakers') this.minSpeakers, @JsonKey(name: 'max_speakers') this.maxSpeakers, this.hotwords, @JsonKey(name: 'initial_prompt') this.initialPrompt}): _tags = tags;
  factory _Recording.fromJson(Map<String, dynamic> json) => _$RecordingFromJson(json);

@override final  int id;
@override final  String? title;
@override@JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate) final  DateTime? meetingDate;
@override@JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) final  DateTime? createdAt;
@override final  String? participants;
@override@JsonKey(name: 'file_size') final  int? fileSize;
@override@JsonKey(name: 'is_highlighted') final  bool isHighlighted;
@override@JsonKey(name: 'is_archived') final  bool isArchived;
@override@JsonKey(name: 'is_inbox') final  bool isInbox;
@override@JsonKey(fromJson: _parseRecordingStatus) final  RecordingStatus status;
 final  List<Tag> _tags;
@override@JsonKey() List<Tag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'folder_id') final  int? folderId;
@override final  Folder? folder;
// Returned by the v1 list endpoint.
@override@JsonKey(name: 'audio_available') final  bool? audioAvailable;
@override@JsonKey(name: 'error_message') final  String? errorMessage;
@override@JsonKey(name: 'has_summary') final  bool? hasSummary;
@override@JsonKey(name: 'has_transcription') final  bool? hasTranscription;
@override@JsonKey(name: 'original_filename') final  String? originalFilename;
// Optional rich fields returned by the unofficial /api/recordings/{id}.
@override final  String? summary;
@override final  String? notes;
@override final  String? transcription;
@override@JsonKey(name: 'audio_duration') final  double? audioDuration;
// Optional transcription parameters — present on the unofficial detail
// endpoint when set; absent otherwise. Used to pre-fill the reprocess
// transcription dialog.
@override@JsonKey(name: 'transcription_model') final  String? transcriptionModel;
@override final  String? language;
@override@JsonKey(name: 'min_speakers') final  int? minSpeakers;
@override@JsonKey(name: 'max_speakers') final  int? maxSpeakers;
@override final  String? hotwords;
@override@JsonKey(name: 'initial_prompt') final  String? initialPrompt;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingCopyWith<_Recording> get copyWith => __$RecordingCopyWithImpl<_Recording>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recording&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.meetingDate, meetingDate) || other.meetingDate == meetingDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.isHighlighted, isHighlighted) || other.isHighlighted == isHighlighted)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isInbox, isInbox) || other.isInbox == isInbox)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.folder, folder) || other.folder == folder)&&(identical(other.audioAvailable, audioAvailable) || other.audioAvailable == audioAvailable)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasSummary, hasSummary) || other.hasSummary == hasSummary)&&(identical(other.hasTranscription, hasTranscription) || other.hasTranscription == hasTranscription)&&(identical(other.originalFilename, originalFilename) || other.originalFilename == originalFilename)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.transcription, transcription) || other.transcription == transcription)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&(identical(other.transcriptionModel, transcriptionModel) || other.transcriptionModel == transcriptionModel)&&(identical(other.language, language) || other.language == language)&&(identical(other.minSpeakers, minSpeakers) || other.minSpeakers == minSpeakers)&&(identical(other.maxSpeakers, maxSpeakers) || other.maxSpeakers == maxSpeakers)&&(identical(other.hotwords, hotwords) || other.hotwords == hotwords)&&(identical(other.initialPrompt, initialPrompt) || other.initialPrompt == initialPrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,meetingDate,createdAt,participants,fileSize,isHighlighted,isArchived,isInbox,status,const DeepCollectionEquality().hash(_tags),folderId,folder,audioAvailable,errorMessage,hasSummary,hasTranscription,originalFilename,summary,notes,transcription,audioDuration,transcriptionModel,language,minSpeakers,maxSpeakers,hotwords,initialPrompt]);

@override
String toString() {
  return 'Recording(id: $id, title: $title, meetingDate: $meetingDate, createdAt: $createdAt, participants: $participants, fileSize: $fileSize, isHighlighted: $isHighlighted, isArchived: $isArchived, isInbox: $isInbox, status: $status, tags: $tags, folderId: $folderId, folder: $folder, audioAvailable: $audioAvailable, errorMessage: $errorMessage, hasSummary: $hasSummary, hasTranscription: $hasTranscription, originalFilename: $originalFilename, summary: $summary, notes: $notes, transcription: $transcription, audioDuration: $audioDuration, transcriptionModel: $transcriptionModel, language: $language, minSpeakers: $minSpeakers, maxSpeakers: $maxSpeakers, hotwords: $hotwords, initialPrompt: $initialPrompt)';
}


}

/// @nodoc
abstract mixin class _$RecordingCopyWith<$Res> implements $RecordingCopyWith<$Res> {
  factory _$RecordingCopyWith(_Recording value, $Res Function(_Recording) _then) = __$RecordingCopyWithImpl;
@override @useResult
$Res call({
 int id, String? title,@JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate) DateTime? meetingDate,@JsonKey(name: 'created_at', fromJson: _parseFlexibleDate) DateTime? createdAt, String? participants,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'is_highlighted') bool isHighlighted,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_inbox') bool isInbox,@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status, List<Tag> tags,@JsonKey(name: 'folder_id') int? folderId, Folder? folder,@JsonKey(name: 'audio_available') bool? audioAvailable,@JsonKey(name: 'error_message') String? errorMessage,@JsonKey(name: 'has_summary') bool? hasSummary,@JsonKey(name: 'has_transcription') bool? hasTranscription,@JsonKey(name: 'original_filename') String? originalFilename, String? summary, String? notes, String? transcription,@JsonKey(name: 'audio_duration') double? audioDuration,@JsonKey(name: 'transcription_model') String? transcriptionModel, String? language,@JsonKey(name: 'min_speakers') int? minSpeakers,@JsonKey(name: 'max_speakers') int? maxSpeakers, String? hotwords,@JsonKey(name: 'initial_prompt') String? initialPrompt
});


@override $FolderCopyWith<$Res>? get folder;

}
/// @nodoc
class __$RecordingCopyWithImpl<$Res>
    implements _$RecordingCopyWith<$Res> {
  __$RecordingCopyWithImpl(this._self, this._then);

  final _Recording _self;
  final $Res Function(_Recording) _then;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? meetingDate = freezed,Object? createdAt = freezed,Object? participants = freezed,Object? fileSize = freezed,Object? isHighlighted = null,Object? isArchived = null,Object? isInbox = null,Object? status = null,Object? tags = null,Object? folderId = freezed,Object? folder = freezed,Object? audioAvailable = freezed,Object? errorMessage = freezed,Object? hasSummary = freezed,Object? hasTranscription = freezed,Object? originalFilename = freezed,Object? summary = freezed,Object? notes = freezed,Object? transcription = freezed,Object? audioDuration = freezed,Object? transcriptionModel = freezed,Object? language = freezed,Object? minSpeakers = freezed,Object? maxSpeakers = freezed,Object? hotwords = freezed,Object? initialPrompt = freezed,}) {
  return _then(_Recording(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,meetingDate: freezed == meetingDate ? _self.meetingDate : meetingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,participants: freezed == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,isHighlighted: null == isHighlighted ? _self.isHighlighted : isHighlighted // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isInbox: null == isInbox ? _self.isInbox : isInbox // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as int?,folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as Folder?,audioAvailable: freezed == audioAvailable ? _self.audioAvailable : audioAvailable // ignore: cast_nullable_to_non_nullable
as bool?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasSummary: freezed == hasSummary ? _self.hasSummary : hasSummary // ignore: cast_nullable_to_non_nullable
as bool?,hasTranscription: freezed == hasTranscription ? _self.hasTranscription : hasTranscription // ignore: cast_nullable_to_non_nullable
as bool?,originalFilename: freezed == originalFilename ? _self.originalFilename : originalFilename // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,transcription: freezed == transcription ? _self.transcription : transcription // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as double?,transcriptionModel: freezed == transcriptionModel ? _self.transcriptionModel : transcriptionModel // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,minSpeakers: freezed == minSpeakers ? _self.minSpeakers : minSpeakers // ignore: cast_nullable_to_non_nullable
as int?,maxSpeakers: freezed == maxSpeakers ? _self.maxSpeakers : maxSpeakers // ignore: cast_nullable_to_non_nullable
as int?,hotwords: freezed == hotwords ? _self.hotwords : hotwords // ignore: cast_nullable_to_non_nullable
as String?,initialPrompt: freezed == initialPrompt ? _self.initialPrompt : initialPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FolderCopyWith<$Res>? get folder {
    if (_self.folder == null) {
    return null;
  }

  return $FolderCopyWith<$Res>(_self.folder!, (value) {
    return _then(_self.copyWith(folder: value));
  });
}
}


/// @nodoc
mixin _$TranscriptionModelOption {

 String get label; String get value;
/// Create a copy of TranscriptionModelOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptionModelOptionCopyWith<TranscriptionModelOption> get copyWith => _$TranscriptionModelOptionCopyWithImpl<TranscriptionModelOption>(this as TranscriptionModelOption, _$identity);

  /// Serializes this TranscriptionModelOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptionModelOption&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'TranscriptionModelOption(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class $TranscriptionModelOptionCopyWith<$Res>  {
  factory $TranscriptionModelOptionCopyWith(TranscriptionModelOption value, $Res Function(TranscriptionModelOption) _then) = _$TranscriptionModelOptionCopyWithImpl;
@useResult
$Res call({
 String label, String value
});




}
/// @nodoc
class _$TranscriptionModelOptionCopyWithImpl<$Res>
    implements $TranscriptionModelOptionCopyWith<$Res> {
  _$TranscriptionModelOptionCopyWithImpl(this._self, this._then);

  final TranscriptionModelOption _self;
  final $Res Function(TranscriptionModelOption) _then;

/// Create a copy of TranscriptionModelOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptionModelOption].
extension TranscriptionModelOptionPatterns on TranscriptionModelOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptionModelOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptionModelOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptionModelOption value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptionModelOption():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptionModelOption value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptionModelOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptionModelOption() when $default != null:
return $default(_that.label,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value)  $default,) {final _that = this;
switch (_that) {
case _TranscriptionModelOption():
return $default(_that.label,_that.value);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptionModelOption() when $default != null:
return $default(_that.label,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptionModelOption implements TranscriptionModelOption {
  const _TranscriptionModelOption({required this.label, required this.value});
  factory _TranscriptionModelOption.fromJson(Map<String, dynamic> json) => _$TranscriptionModelOptionFromJson(json);

@override final  String label;
@override final  String value;

/// Create a copy of TranscriptionModelOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptionModelOptionCopyWith<_TranscriptionModelOption> get copyWith => __$TranscriptionModelOptionCopyWithImpl<_TranscriptionModelOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptionModelOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptionModelOption&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'TranscriptionModelOption(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class _$TranscriptionModelOptionCopyWith<$Res> implements $TranscriptionModelOptionCopyWith<$Res> {
  factory _$TranscriptionModelOptionCopyWith(_TranscriptionModelOption value, $Res Function(_TranscriptionModelOption) _then) = __$TranscriptionModelOptionCopyWithImpl;
@override @useResult
$Res call({
 String label, String value
});




}
/// @nodoc
class __$TranscriptionModelOptionCopyWithImpl<$Res>
    implements _$TranscriptionModelOptionCopyWith<$Res> {
  __$TranscriptionModelOptionCopyWithImpl(this._self, this._then);

  final _TranscriptionModelOption _self;
  final $Res Function(_TranscriptionModelOption) _then;

/// Create a copy of TranscriptionModelOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,}) {
  return _then(_TranscriptionModelOption(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Config {

@JsonKey(name: 'transcription_model_options') List<TranscriptionModelOption> get transcriptionModelOptions;@JsonKey(name: 'connector_supports_diarization') bool get connectorSupportsDiarization;@JsonKey(name: 'connector_supports_speaker_count') bool get connectorSupportsSpeakerCount;@JsonKey(name: 'connector_supports_hotwords') bool get connectorSupportsHotwords;@JsonKey(name: 'connector_supports_initial_prompt') bool get connectorSupportsInitialPrompt;// Server keeps the video stream of uploads (VIDEO_RETENTION). When
// false, an uploaded .mp4 is reduced to its audio.
@JsonKey(name: 'video_retention') bool get videoRetention;// Upload limit for files the server stores as-is, video included.
@JsonKey(name: 'max_file_size_mb') int? get maxFileSizeMb;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&const DeepCollectionEquality().equals(other.transcriptionModelOptions, transcriptionModelOptions)&&(identical(other.connectorSupportsDiarization, connectorSupportsDiarization) || other.connectorSupportsDiarization == connectorSupportsDiarization)&&(identical(other.connectorSupportsSpeakerCount, connectorSupportsSpeakerCount) || other.connectorSupportsSpeakerCount == connectorSupportsSpeakerCount)&&(identical(other.connectorSupportsHotwords, connectorSupportsHotwords) || other.connectorSupportsHotwords == connectorSupportsHotwords)&&(identical(other.connectorSupportsInitialPrompt, connectorSupportsInitialPrompt) || other.connectorSupportsInitialPrompt == connectorSupportsInitialPrompt)&&(identical(other.videoRetention, videoRetention) || other.videoRetention == videoRetention)&&(identical(other.maxFileSizeMb, maxFileSizeMb) || other.maxFileSizeMb == maxFileSizeMb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transcriptionModelOptions),connectorSupportsDiarization,connectorSupportsSpeakerCount,connectorSupportsHotwords,connectorSupportsInitialPrompt,videoRetention,maxFileSizeMb);

@override
String toString() {
  return 'Config(transcriptionModelOptions: $transcriptionModelOptions, connectorSupportsDiarization: $connectorSupportsDiarization, connectorSupportsSpeakerCount: $connectorSupportsSpeakerCount, connectorSupportsHotwords: $connectorSupportsHotwords, connectorSupportsInitialPrompt: $connectorSupportsInitialPrompt, videoRetention: $videoRetention, maxFileSizeMb: $maxFileSizeMb)';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'transcription_model_options') List<TranscriptionModelOption> transcriptionModelOptions,@JsonKey(name: 'connector_supports_diarization') bool connectorSupportsDiarization,@JsonKey(name: 'connector_supports_speaker_count') bool connectorSupportsSpeakerCount,@JsonKey(name: 'connector_supports_hotwords') bool connectorSupportsHotwords,@JsonKey(name: 'connector_supports_initial_prompt') bool connectorSupportsInitialPrompt,@JsonKey(name: 'video_retention') bool videoRetention,@JsonKey(name: 'max_file_size_mb') int? maxFileSizeMb
});




}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transcriptionModelOptions = null,Object? connectorSupportsDiarization = null,Object? connectorSupportsSpeakerCount = null,Object? connectorSupportsHotwords = null,Object? connectorSupportsInitialPrompt = null,Object? videoRetention = null,Object? maxFileSizeMb = freezed,}) {
  return _then(_self.copyWith(
transcriptionModelOptions: null == transcriptionModelOptions ? _self.transcriptionModelOptions : transcriptionModelOptions // ignore: cast_nullable_to_non_nullable
as List<TranscriptionModelOption>,connectorSupportsDiarization: null == connectorSupportsDiarization ? _self.connectorSupportsDiarization : connectorSupportsDiarization // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsSpeakerCount: null == connectorSupportsSpeakerCount ? _self.connectorSupportsSpeakerCount : connectorSupportsSpeakerCount // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsHotwords: null == connectorSupportsHotwords ? _self.connectorSupportsHotwords : connectorSupportsHotwords // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsInitialPrompt: null == connectorSupportsInitialPrompt ? _self.connectorSupportsInitialPrompt : connectorSupportsInitialPrompt // ignore: cast_nullable_to_non_nullable
as bool,videoRetention: null == videoRetention ? _self.videoRetention : videoRetention // ignore: cast_nullable_to_non_nullable
as bool,maxFileSizeMb: freezed == maxFileSizeMb ? _self.maxFileSizeMb : maxFileSizeMb // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'transcription_model_options')  List<TranscriptionModelOption> transcriptionModelOptions, @JsonKey(name: 'connector_supports_diarization')  bool connectorSupportsDiarization, @JsonKey(name: 'connector_supports_speaker_count')  bool connectorSupportsSpeakerCount, @JsonKey(name: 'connector_supports_hotwords')  bool connectorSupportsHotwords, @JsonKey(name: 'connector_supports_initial_prompt')  bool connectorSupportsInitialPrompt, @JsonKey(name: 'video_retention')  bool videoRetention, @JsonKey(name: 'max_file_size_mb')  int? maxFileSizeMb)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.transcriptionModelOptions,_that.connectorSupportsDiarization,_that.connectorSupportsSpeakerCount,_that.connectorSupportsHotwords,_that.connectorSupportsInitialPrompt,_that.videoRetention,_that.maxFileSizeMb);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'transcription_model_options')  List<TranscriptionModelOption> transcriptionModelOptions, @JsonKey(name: 'connector_supports_diarization')  bool connectorSupportsDiarization, @JsonKey(name: 'connector_supports_speaker_count')  bool connectorSupportsSpeakerCount, @JsonKey(name: 'connector_supports_hotwords')  bool connectorSupportsHotwords, @JsonKey(name: 'connector_supports_initial_prompt')  bool connectorSupportsInitialPrompt, @JsonKey(name: 'video_retention')  bool videoRetention, @JsonKey(name: 'max_file_size_mb')  int? maxFileSizeMb)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.transcriptionModelOptions,_that.connectorSupportsDiarization,_that.connectorSupportsSpeakerCount,_that.connectorSupportsHotwords,_that.connectorSupportsInitialPrompt,_that.videoRetention,_that.maxFileSizeMb);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'transcription_model_options')  List<TranscriptionModelOption> transcriptionModelOptions, @JsonKey(name: 'connector_supports_diarization')  bool connectorSupportsDiarization, @JsonKey(name: 'connector_supports_speaker_count')  bool connectorSupportsSpeakerCount, @JsonKey(name: 'connector_supports_hotwords')  bool connectorSupportsHotwords, @JsonKey(name: 'connector_supports_initial_prompt')  bool connectorSupportsInitialPrompt, @JsonKey(name: 'video_retention')  bool videoRetention, @JsonKey(name: 'max_file_size_mb')  int? maxFileSizeMb)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.transcriptionModelOptions,_that.connectorSupportsDiarization,_that.connectorSupportsSpeakerCount,_that.connectorSupportsHotwords,_that.connectorSupportsInitialPrompt,_that.videoRetention,_that.maxFileSizeMb);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({@JsonKey(name: 'transcription_model_options') final  List<TranscriptionModelOption> transcriptionModelOptions = const <TranscriptionModelOption>[], @JsonKey(name: 'connector_supports_diarization') this.connectorSupportsDiarization = false, @JsonKey(name: 'connector_supports_speaker_count') this.connectorSupportsSpeakerCount = false, @JsonKey(name: 'connector_supports_hotwords') this.connectorSupportsHotwords = false, @JsonKey(name: 'connector_supports_initial_prompt') this.connectorSupportsInitialPrompt = false, @JsonKey(name: 'video_retention') this.videoRetention = false, @JsonKey(name: 'max_file_size_mb') this.maxFileSizeMb}): _transcriptionModelOptions = transcriptionModelOptions;
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

 final  List<TranscriptionModelOption> _transcriptionModelOptions;
@override@JsonKey(name: 'transcription_model_options') List<TranscriptionModelOption> get transcriptionModelOptions {
  if (_transcriptionModelOptions is EqualUnmodifiableListView) return _transcriptionModelOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transcriptionModelOptions);
}

@override@JsonKey(name: 'connector_supports_diarization') final  bool connectorSupportsDiarization;
@override@JsonKey(name: 'connector_supports_speaker_count') final  bool connectorSupportsSpeakerCount;
@override@JsonKey(name: 'connector_supports_hotwords') final  bool connectorSupportsHotwords;
@override@JsonKey(name: 'connector_supports_initial_prompt') final  bool connectorSupportsInitialPrompt;
// Server keeps the video stream of uploads (VIDEO_RETENTION). When
// false, an uploaded .mp4 is reduced to its audio.
@override@JsonKey(name: 'video_retention') final  bool videoRetention;
// Upload limit for files the server stores as-is, video included.
@override@JsonKey(name: 'max_file_size_mb') final  int? maxFileSizeMb;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&const DeepCollectionEquality().equals(other._transcriptionModelOptions, _transcriptionModelOptions)&&(identical(other.connectorSupportsDiarization, connectorSupportsDiarization) || other.connectorSupportsDiarization == connectorSupportsDiarization)&&(identical(other.connectorSupportsSpeakerCount, connectorSupportsSpeakerCount) || other.connectorSupportsSpeakerCount == connectorSupportsSpeakerCount)&&(identical(other.connectorSupportsHotwords, connectorSupportsHotwords) || other.connectorSupportsHotwords == connectorSupportsHotwords)&&(identical(other.connectorSupportsInitialPrompt, connectorSupportsInitialPrompt) || other.connectorSupportsInitialPrompt == connectorSupportsInitialPrompt)&&(identical(other.videoRetention, videoRetention) || other.videoRetention == videoRetention)&&(identical(other.maxFileSizeMb, maxFileSizeMb) || other.maxFileSizeMb == maxFileSizeMb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transcriptionModelOptions),connectorSupportsDiarization,connectorSupportsSpeakerCount,connectorSupportsHotwords,connectorSupportsInitialPrompt,videoRetention,maxFileSizeMb);

@override
String toString() {
  return 'Config(transcriptionModelOptions: $transcriptionModelOptions, connectorSupportsDiarization: $connectorSupportsDiarization, connectorSupportsSpeakerCount: $connectorSupportsSpeakerCount, connectorSupportsHotwords: $connectorSupportsHotwords, connectorSupportsInitialPrompt: $connectorSupportsInitialPrompt, videoRetention: $videoRetention, maxFileSizeMb: $maxFileSizeMb)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'transcription_model_options') List<TranscriptionModelOption> transcriptionModelOptions,@JsonKey(name: 'connector_supports_diarization') bool connectorSupportsDiarization,@JsonKey(name: 'connector_supports_speaker_count') bool connectorSupportsSpeakerCount,@JsonKey(name: 'connector_supports_hotwords') bool connectorSupportsHotwords,@JsonKey(name: 'connector_supports_initial_prompt') bool connectorSupportsInitialPrompt,@JsonKey(name: 'video_retention') bool videoRetention,@JsonKey(name: 'max_file_size_mb') int? maxFileSizeMb
});




}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transcriptionModelOptions = null,Object? connectorSupportsDiarization = null,Object? connectorSupportsSpeakerCount = null,Object? connectorSupportsHotwords = null,Object? connectorSupportsInitialPrompt = null,Object? videoRetention = null,Object? maxFileSizeMb = freezed,}) {
  return _then(_Config(
transcriptionModelOptions: null == transcriptionModelOptions ? _self._transcriptionModelOptions : transcriptionModelOptions // ignore: cast_nullable_to_non_nullable
as List<TranscriptionModelOption>,connectorSupportsDiarization: null == connectorSupportsDiarization ? _self.connectorSupportsDiarization : connectorSupportsDiarization // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsSpeakerCount: null == connectorSupportsSpeakerCount ? _self.connectorSupportsSpeakerCount : connectorSupportsSpeakerCount // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsHotwords: null == connectorSupportsHotwords ? _self.connectorSupportsHotwords : connectorSupportsHotwords // ignore: cast_nullable_to_non_nullable
as bool,connectorSupportsInitialPrompt: null == connectorSupportsInitialPrompt ? _self.connectorSupportsInitialPrompt : connectorSupportsInitialPrompt // ignore: cast_nullable_to_non_nullable
as bool,videoRetention: null == videoRetention ? _self.videoRetention : videoRetention // ignore: cast_nullable_to_non_nullable
as bool,maxFileSizeMb: freezed == maxFileSizeMb ? _self.maxFileSizeMb : maxFileSizeMb // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RecordingPage {

 List<Recording> get recordings; int get page;@JsonKey(name: 'per_page') int get perPage; int get total;@JsonKey(name: 'total_pages') int get totalPages;
/// Create a copy of RecordingPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingPageCopyWith<RecordingPage> get copyWith => _$RecordingPageCopyWithImpl<RecordingPage>(this as RecordingPage, _$identity);

  /// Serializes this RecordingPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingPage&&const DeepCollectionEquality().equals(other.recordings, recordings)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(recordings),page,perPage,total,totalPages);

@override
String toString() {
  return 'RecordingPage(recordings: $recordings, page: $page, perPage: $perPage, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $RecordingPageCopyWith<$Res>  {
  factory $RecordingPageCopyWith(RecordingPage value, $Res Function(RecordingPage) _then) = _$RecordingPageCopyWithImpl;
@useResult
$Res call({
 List<Recording> recordings, int page,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class _$RecordingPageCopyWithImpl<$Res>
    implements $RecordingPageCopyWith<$Res> {
  _$RecordingPageCopyWithImpl(this._self, this._then);

  final RecordingPage _self;
  final $Res Function(RecordingPage) _then;

/// Create a copy of RecordingPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordings = null,Object? page = null,Object? perPage = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
recordings: null == recordings ? _self.recordings : recordings // ignore: cast_nullable_to_non_nullable
as List<Recording>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingPage].
extension RecordingPagePatterns on RecordingPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingPage value)  $default,){
final _that = this;
switch (_that) {
case _RecordingPage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingPage value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Recording> recordings,  int page, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'total_pages')  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingPage() when $default != null:
return $default(_that.recordings,_that.page,_that.perPage,_that.total,_that.totalPages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Recording> recordings,  int page, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'total_pages')  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _RecordingPage():
return $default(_that.recordings,_that.page,_that.perPage,_that.total,_that.totalPages);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Recording> recordings,  int page, @JsonKey(name: 'per_page')  int perPage,  int total, @JsonKey(name: 'total_pages')  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _RecordingPage() when $default != null:
return $default(_that.recordings,_that.page,_that.perPage,_that.total,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecordingPage implements RecordingPage {
  const _RecordingPage({final  List<Recording> recordings = const <Recording>[], this.page = 1, @JsonKey(name: 'per_page') this.perPage = 25, this.total = 0, @JsonKey(name: 'total_pages') this.totalPages = 1}): _recordings = recordings;
  factory _RecordingPage.fromJson(Map<String, dynamic> json) => _$RecordingPageFromJson(json);

 final  List<Recording> _recordings;
@override@JsonKey() List<Recording> get recordings {
  if (_recordings is EqualUnmodifiableListView) return _recordings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recordings);
}

@override@JsonKey() final  int page;
@override@JsonKey(name: 'per_page') final  int perPage;
@override@JsonKey() final  int total;
@override@JsonKey(name: 'total_pages') final  int totalPages;

/// Create a copy of RecordingPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingPageCopyWith<_RecordingPage> get copyWith => __$RecordingPageCopyWithImpl<_RecordingPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordingPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingPage&&const DeepCollectionEquality().equals(other._recordings, _recordings)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_recordings),page,perPage,total,totalPages);

@override
String toString() {
  return 'RecordingPage(recordings: $recordings, page: $page, perPage: $perPage, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$RecordingPageCopyWith<$Res> implements $RecordingPageCopyWith<$Res> {
  factory _$RecordingPageCopyWith(_RecordingPage value, $Res Function(_RecordingPage) _then) = __$RecordingPageCopyWithImpl;
@override @useResult
$Res call({
 List<Recording> recordings, int page,@JsonKey(name: 'per_page') int perPage, int total,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class __$RecordingPageCopyWithImpl<$Res>
    implements _$RecordingPageCopyWith<$Res> {
  __$RecordingPageCopyWithImpl(this._self, this._then);

  final _RecordingPage _self;
  final $Res Function(_RecordingPage) _then;

/// Create a copy of RecordingPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordings = null,Object? page = null,Object? perPage = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_RecordingPage(
recordings: null == recordings ? _self._recordings : recordings // ignore: cast_nullable_to_non_nullable
as List<Recording>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TranscriptSegment {

 String? get speaker;@JsonKey(name: 'start_time') double? get startTime;@JsonKey(name: 'end_time') double? get endTime; String? get sentence;
/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptSegmentCopyWith<TranscriptSegment> get copyWith => _$TranscriptSegmentCopyWithImpl<TranscriptSegment>(this as TranscriptSegment, _$identity);

  /// Serializes this TranscriptSegment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptSegment&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.sentence, sentence) || other.sentence == sentence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,speaker,startTime,endTime,sentence);

@override
String toString() {
  return 'TranscriptSegment(speaker: $speaker, startTime: $startTime, endTime: $endTime, sentence: $sentence)';
}


}

/// @nodoc
abstract mixin class $TranscriptSegmentCopyWith<$Res>  {
  factory $TranscriptSegmentCopyWith(TranscriptSegment value, $Res Function(TranscriptSegment) _then) = _$TranscriptSegmentCopyWithImpl;
@useResult
$Res call({
 String? speaker,@JsonKey(name: 'start_time') double? startTime,@JsonKey(name: 'end_time') double? endTime, String? sentence
});




}
/// @nodoc
class _$TranscriptSegmentCopyWithImpl<$Res>
    implements $TranscriptSegmentCopyWith<$Res> {
  _$TranscriptSegmentCopyWithImpl(this._self, this._then);

  final TranscriptSegment _self;
  final $Res Function(TranscriptSegment) _then;

/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speaker = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? sentence = freezed,}) {
  return _then(_self.copyWith(
speaker: freezed == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as double?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as double?,sentence: freezed == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptSegment].
extension TranscriptSegmentPatterns on TranscriptSegment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptSegment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptSegment value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptSegment():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptSegment value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? speaker, @JsonKey(name: 'start_time')  double? startTime, @JsonKey(name: 'end_time')  double? endTime,  String? sentence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that.speaker,_that.startTime,_that.endTime,_that.sentence);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? speaker, @JsonKey(name: 'start_time')  double? startTime, @JsonKey(name: 'end_time')  double? endTime,  String? sentence)  $default,) {final _that = this;
switch (_that) {
case _TranscriptSegment():
return $default(_that.speaker,_that.startTime,_that.endTime,_that.sentence);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? speaker, @JsonKey(name: 'start_time')  double? startTime, @JsonKey(name: 'end_time')  double? endTime,  String? sentence)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that.speaker,_that.startTime,_that.endTime,_that.sentence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptSegment implements TranscriptSegment {
  const _TranscriptSegment({this.speaker, @JsonKey(name: 'start_time') this.startTime, @JsonKey(name: 'end_time') this.endTime, this.sentence});
  factory _TranscriptSegment.fromJson(Map<String, dynamic> json) => _$TranscriptSegmentFromJson(json);

@override final  String? speaker;
@override@JsonKey(name: 'start_time') final  double? startTime;
@override@JsonKey(name: 'end_time') final  double? endTime;
@override final  String? sentence;

/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptSegmentCopyWith<_TranscriptSegment> get copyWith => __$TranscriptSegmentCopyWithImpl<_TranscriptSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptSegment&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.sentence, sentence) || other.sentence == sentence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,speaker,startTime,endTime,sentence);

@override
String toString() {
  return 'TranscriptSegment(speaker: $speaker, startTime: $startTime, endTime: $endTime, sentence: $sentence)';
}


}

/// @nodoc
abstract mixin class _$TranscriptSegmentCopyWith<$Res> implements $TranscriptSegmentCopyWith<$Res> {
  factory _$TranscriptSegmentCopyWith(_TranscriptSegment value, $Res Function(_TranscriptSegment) _then) = __$TranscriptSegmentCopyWithImpl;
@override @useResult
$Res call({
 String? speaker,@JsonKey(name: 'start_time') double? startTime,@JsonKey(name: 'end_time') double? endTime, String? sentence
});




}
/// @nodoc
class __$TranscriptSegmentCopyWithImpl<$Res>
    implements _$TranscriptSegmentCopyWith<$Res> {
  __$TranscriptSegmentCopyWithImpl(this._self, this._then);

  final _TranscriptSegment _self;
  final $Res Function(_TranscriptSegment) _then;

/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speaker = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? sentence = freezed,}) {
  return _then(_TranscriptSegment(
speaker: freezed == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as double?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as double?,sentence: freezed == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecordingStatusResponse {

@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus get status;@JsonKey(name: 'queue_position') int? get queuePosition; String? get message;
/// Create a copy of RecordingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingStatusResponseCopyWith<RecordingStatusResponse> get copyWith => _$RecordingStatusResponseCopyWithImpl<RecordingStatusResponse>(this as RecordingStatusResponse, _$identity);

  /// Serializes this RecordingStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingStatusResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.queuePosition, queuePosition) || other.queuePosition == queuePosition)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,queuePosition,message);

@override
String toString() {
  return 'RecordingStatusResponse(status: $status, queuePosition: $queuePosition, message: $message)';
}


}

/// @nodoc
abstract mixin class $RecordingStatusResponseCopyWith<$Res>  {
  factory $RecordingStatusResponseCopyWith(RecordingStatusResponse value, $Res Function(RecordingStatusResponse) _then) = _$RecordingStatusResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,@JsonKey(name: 'queue_position') int? queuePosition, String? message
});




}
/// @nodoc
class _$RecordingStatusResponseCopyWithImpl<$Res>
    implements $RecordingStatusResponseCopyWith<$Res> {
  _$RecordingStatusResponseCopyWithImpl(this._self, this._then);

  final RecordingStatusResponse _self;
  final $Res Function(RecordingStatusResponse) _then;

/// Create a copy of RecordingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? queuePosition = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,queuePosition: freezed == queuePosition ? _self.queuePosition : queuePosition // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingStatusResponse].
extension RecordingStatusResponsePatterns on RecordingStatusResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingStatusResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecordingStatusResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingStatusResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status, @JsonKey(name: 'queue_position')  int? queuePosition,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingStatusResponse() when $default != null:
return $default(_that.status,_that.queuePosition,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status, @JsonKey(name: 'queue_position')  int? queuePosition,  String? message)  $default,) {final _that = this;
switch (_that) {
case _RecordingStatusResponse():
return $default(_that.status,_that.queuePosition,_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _parseRecordingStatus)  RecordingStatus status, @JsonKey(name: 'queue_position')  int? queuePosition,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _RecordingStatusResponse() when $default != null:
return $default(_that.status,_that.queuePosition,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecordingStatusResponse implements RecordingStatusResponse {
  const _RecordingStatusResponse({@JsonKey(fromJson: _parseRecordingStatus) required this.status, @JsonKey(name: 'queue_position') this.queuePosition, this.message});
  factory _RecordingStatusResponse.fromJson(Map<String, dynamic> json) => _$RecordingStatusResponseFromJson(json);

@override@JsonKey(fromJson: _parseRecordingStatus) final  RecordingStatus status;
@override@JsonKey(name: 'queue_position') final  int? queuePosition;
@override final  String? message;

/// Create a copy of RecordingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingStatusResponseCopyWith<_RecordingStatusResponse> get copyWith => __$RecordingStatusResponseCopyWithImpl<_RecordingStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordingStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingStatusResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.queuePosition, queuePosition) || other.queuePosition == queuePosition)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,queuePosition,message);

@override
String toString() {
  return 'RecordingStatusResponse(status: $status, queuePosition: $queuePosition, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RecordingStatusResponseCopyWith<$Res> implements $RecordingStatusResponseCopyWith<$Res> {
  factory _$RecordingStatusResponseCopyWith(_RecordingStatusResponse value, $Res Function(_RecordingStatusResponse) _then) = __$RecordingStatusResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _parseRecordingStatus) RecordingStatus status,@JsonKey(name: 'queue_position') int? queuePosition, String? message
});




}
/// @nodoc
class __$RecordingStatusResponseCopyWithImpl<$Res>
    implements _$RecordingStatusResponseCopyWith<$Res> {
  __$RecordingStatusResponseCopyWithImpl(this._self, this._then);

  final _RecordingStatusResponse _self;
  final $Res Function(_RecordingStatusResponse) _then;

/// Create a copy of RecordingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? queuePosition = freezed,Object? message = freezed,}) {
  return _then(_RecordingStatusResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,queuePosition: freezed == queuePosition ? _self.queuePosition : queuePosition // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatMessage {

 String get role;// "user" | "assistant"
 String get text;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,text);

@override
String toString() {
  return 'ChatMessage(role: $role, text: $text)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String role, String text
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? text = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.role,_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String text)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.role,_that.text);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String text)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.role,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.role, required this.text});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String role;
// "user" | "assistant"
@override final  String text;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,text);

@override
String toString() {
  return 'ChatMessage(role: $role, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String role, String text
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? text = null,}) {
  return _then(_ChatMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChatResponse {

@JsonKey(name: 'response') String get response;
/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatResponseCopyWith<ChatResponse> get copyWith => _$ChatResponseCopyWithImpl<ChatResponse>(this as ChatResponse, _$identity);

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatResponse&&(identical(other.response, response) || other.response == response));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'ChatResponse(response: $response)';
}


}

/// @nodoc
abstract mixin class $ChatResponseCopyWith<$Res>  {
  factory $ChatResponseCopyWith(ChatResponse value, $Res Function(ChatResponse) _then) = _$ChatResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'response') String response
});




}
/// @nodoc
class _$ChatResponseCopyWithImpl<$Res>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._self, this._then);

  final ChatResponse _self;
  final $Res Function(ChatResponse) _then;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? response = null,}) {
  return _then(_self.copyWith(
response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatResponse].
extension ChatResponsePatterns on ChatResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'response')  String response)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatResponse() when $default != null:
return $default(_that.response);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'response')  String response)  $default,) {final _that = this;
switch (_that) {
case _ChatResponse():
return $default(_that.response);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'response')  String response)?  $default,) {final _that = this;
switch (_that) {
case _ChatResponse() when $default != null:
return $default(_that.response);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatResponse implements ChatResponse {
  const _ChatResponse({@JsonKey(name: 'response') required this.response});
  factory _ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);

@override@JsonKey(name: 'response') final  String response;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatResponseCopyWith<_ChatResponse> get copyWith => __$ChatResponseCopyWithImpl<_ChatResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatResponse&&(identical(other.response, response) || other.response == response));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'ChatResponse(response: $response)';
}


}

/// @nodoc
abstract mixin class _$ChatResponseCopyWith<$Res> implements $ChatResponseCopyWith<$Res> {
  factory _$ChatResponseCopyWith(_ChatResponse value, $Res Function(_ChatResponse) _then) = __$ChatResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'response') String response
});




}
/// @nodoc
class __$ChatResponseCopyWithImpl<$Res>
    implements _$ChatResponseCopyWith<$Res> {
  __$ChatResponseCopyWithImpl(this._self, this._then);

  final _ChatResponse _self;
  final $Res Function(_ChatResponse) _then;

/// Create a copy of ChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(_ChatResponse(
response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StatsResponse {

 StatsActivity? get activity; StatsQueue? get queue; StatsRecordings? get recordings; StatsStorage? get storage; StatsTokens? get tokens; StatsTranscription? get transcription;
/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsResponseCopyWith<StatsResponse> get copyWith => _$StatsResponseCopyWithImpl<StatsResponse>(this as StatsResponse, _$identity);

  /// Serializes this StatsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsResponse&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.queue, queue) || other.queue == queue)&&(identical(other.recordings, recordings) || other.recordings == recordings)&&(identical(other.storage, storage) || other.storage == storage)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.transcription, transcription) || other.transcription == transcription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activity,queue,recordings,storage,tokens,transcription);

@override
String toString() {
  return 'StatsResponse(activity: $activity, queue: $queue, recordings: $recordings, storage: $storage, tokens: $tokens, transcription: $transcription)';
}


}

/// @nodoc
abstract mixin class $StatsResponseCopyWith<$Res>  {
  factory $StatsResponseCopyWith(StatsResponse value, $Res Function(StatsResponse) _then) = _$StatsResponseCopyWithImpl;
@useResult
$Res call({
 StatsActivity? activity, StatsQueue? queue, StatsRecordings? recordings, StatsStorage? storage, StatsTokens? tokens, StatsTranscription? transcription
});


$StatsActivityCopyWith<$Res>? get activity;$StatsQueueCopyWith<$Res>? get queue;$StatsRecordingsCopyWith<$Res>? get recordings;$StatsStorageCopyWith<$Res>? get storage;$StatsTokensCopyWith<$Res>? get tokens;$StatsTranscriptionCopyWith<$Res>? get transcription;

}
/// @nodoc
class _$StatsResponseCopyWithImpl<$Res>
    implements $StatsResponseCopyWith<$Res> {
  _$StatsResponseCopyWithImpl(this._self, this._then);

  final StatsResponse _self;
  final $Res Function(StatsResponse) _then;

/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activity = freezed,Object? queue = freezed,Object? recordings = freezed,Object? storage = freezed,Object? tokens = freezed,Object? transcription = freezed,}) {
  return _then(_self.copyWith(
activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as StatsActivity?,queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as StatsQueue?,recordings: freezed == recordings ? _self.recordings : recordings // ignore: cast_nullable_to_non_nullable
as StatsRecordings?,storage: freezed == storage ? _self.storage : storage // ignore: cast_nullable_to_non_nullable
as StatsStorage?,tokens: freezed == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as StatsTokens?,transcription: freezed == transcription ? _self.transcription : transcription // ignore: cast_nullable_to_non_nullable
as StatsTranscription?,
  ));
}
/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsActivityCopyWith<$Res>? get activity {
    if (_self.activity == null) {
    return null;
  }

  return $StatsActivityCopyWith<$Res>(_self.activity!, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsQueueCopyWith<$Res>? get queue {
    if (_self.queue == null) {
    return null;
  }

  return $StatsQueueCopyWith<$Res>(_self.queue!, (value) {
    return _then(_self.copyWith(queue: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsRecordingsCopyWith<$Res>? get recordings {
    if (_self.recordings == null) {
    return null;
  }

  return $StatsRecordingsCopyWith<$Res>(_self.recordings!, (value) {
    return _then(_self.copyWith(recordings: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsStorageCopyWith<$Res>? get storage {
    if (_self.storage == null) {
    return null;
  }

  return $StatsStorageCopyWith<$Res>(_self.storage!, (value) {
    return _then(_self.copyWith(storage: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsTokensCopyWith<$Res>? get tokens {
    if (_self.tokens == null) {
    return null;
  }

  return $StatsTokensCopyWith<$Res>(_self.tokens!, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsTranscriptionCopyWith<$Res>? get transcription {
    if (_self.transcription == null) {
    return null;
  }

  return $StatsTranscriptionCopyWith<$Res>(_self.transcription!, (value) {
    return _then(_self.copyWith(transcription: value));
  });
}
}


/// Adds pattern-matching-related methods to [StatsResponse].
extension StatsResponsePatterns on StatsResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsResponse value)  $default,){
final _that = this;
switch (_that) {
case _StatsResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _StatsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StatsActivity? activity,  StatsQueue? queue,  StatsRecordings? recordings,  StatsStorage? storage,  StatsTokens? tokens,  StatsTranscription? transcription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsResponse() when $default != null:
return $default(_that.activity,_that.queue,_that.recordings,_that.storage,_that.tokens,_that.transcription);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StatsActivity? activity,  StatsQueue? queue,  StatsRecordings? recordings,  StatsStorage? storage,  StatsTokens? tokens,  StatsTranscription? transcription)  $default,) {final _that = this;
switch (_that) {
case _StatsResponse():
return $default(_that.activity,_that.queue,_that.recordings,_that.storage,_that.tokens,_that.transcription);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StatsActivity? activity,  StatsQueue? queue,  StatsRecordings? recordings,  StatsStorage? storage,  StatsTokens? tokens,  StatsTranscription? transcription)?  $default,) {final _that = this;
switch (_that) {
case _StatsResponse() when $default != null:
return $default(_that.activity,_that.queue,_that.recordings,_that.storage,_that.tokens,_that.transcription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsResponse implements StatsResponse {
  const _StatsResponse({this.activity, this.queue, this.recordings, this.storage, this.tokens, this.transcription});
  factory _StatsResponse.fromJson(Map<String, dynamic> json) => _$StatsResponseFromJson(json);

@override final  StatsActivity? activity;
@override final  StatsQueue? queue;
@override final  StatsRecordings? recordings;
@override final  StatsStorage? storage;
@override final  StatsTokens? tokens;
@override final  StatsTranscription? transcription;

/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsResponseCopyWith<_StatsResponse> get copyWith => __$StatsResponseCopyWithImpl<_StatsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsResponse&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.queue, queue) || other.queue == queue)&&(identical(other.recordings, recordings) || other.recordings == recordings)&&(identical(other.storage, storage) || other.storage == storage)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.transcription, transcription) || other.transcription == transcription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activity,queue,recordings,storage,tokens,transcription);

@override
String toString() {
  return 'StatsResponse(activity: $activity, queue: $queue, recordings: $recordings, storage: $storage, tokens: $tokens, transcription: $transcription)';
}


}

/// @nodoc
abstract mixin class _$StatsResponseCopyWith<$Res> implements $StatsResponseCopyWith<$Res> {
  factory _$StatsResponseCopyWith(_StatsResponse value, $Res Function(_StatsResponse) _then) = __$StatsResponseCopyWithImpl;
@override @useResult
$Res call({
 StatsActivity? activity, StatsQueue? queue, StatsRecordings? recordings, StatsStorage? storage, StatsTokens? tokens, StatsTranscription? transcription
});


@override $StatsActivityCopyWith<$Res>? get activity;@override $StatsQueueCopyWith<$Res>? get queue;@override $StatsRecordingsCopyWith<$Res>? get recordings;@override $StatsStorageCopyWith<$Res>? get storage;@override $StatsTokensCopyWith<$Res>? get tokens;@override $StatsTranscriptionCopyWith<$Res>? get transcription;

}
/// @nodoc
class __$StatsResponseCopyWithImpl<$Res>
    implements _$StatsResponseCopyWith<$Res> {
  __$StatsResponseCopyWithImpl(this._self, this._then);

  final _StatsResponse _self;
  final $Res Function(_StatsResponse) _then;

/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activity = freezed,Object? queue = freezed,Object? recordings = freezed,Object? storage = freezed,Object? tokens = freezed,Object? transcription = freezed,}) {
  return _then(_StatsResponse(
activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as StatsActivity?,queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as StatsQueue?,recordings: freezed == recordings ? _self.recordings : recordings // ignore: cast_nullable_to_non_nullable
as StatsRecordings?,storage: freezed == storage ? _self.storage : storage // ignore: cast_nullable_to_non_nullable
as StatsStorage?,tokens: freezed == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as StatsTokens?,transcription: freezed == transcription ? _self.transcription : transcription // ignore: cast_nullable_to_non_nullable
as StatsTranscription?,
  ));
}

/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsActivityCopyWith<$Res>? get activity {
    if (_self.activity == null) {
    return null;
  }

  return $StatsActivityCopyWith<$Res>(_self.activity!, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsQueueCopyWith<$Res>? get queue {
    if (_self.queue == null) {
    return null;
  }

  return $StatsQueueCopyWith<$Res>(_self.queue!, (value) {
    return _then(_self.copyWith(queue: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsRecordingsCopyWith<$Res>? get recordings {
    if (_self.recordings == null) {
    return null;
  }

  return $StatsRecordingsCopyWith<$Res>(_self.recordings!, (value) {
    return _then(_self.copyWith(recordings: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsStorageCopyWith<$Res>? get storage {
    if (_self.storage == null) {
    return null;
  }

  return $StatsStorageCopyWith<$Res>(_self.storage!, (value) {
    return _then(_self.copyWith(storage: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsTokensCopyWith<$Res>? get tokens {
    if (_self.tokens == null) {
    return null;
  }

  return $StatsTokensCopyWith<$Res>(_self.tokens!, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of StatsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsTranscriptionCopyWith<$Res>? get transcription {
    if (_self.transcription == null) {
    return null;
  }

  return $StatsTranscriptionCopyWith<$Res>(_self.transcription!, (value) {
    return _then(_self.copyWith(transcription: value));
  });
}
}


/// @nodoc
mixin _$StatsActivity {

@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate) DateTime? get lastTranscription;@JsonKey(name: 'recordings_today') int? get recordingsToday;
/// Create a copy of StatsActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsActivityCopyWith<StatsActivity> get copyWith => _$StatsActivityCopyWithImpl<StatsActivity>(this as StatsActivity, _$identity);

  /// Serializes this StatsActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsActivity&&(identical(other.lastTranscription, lastTranscription) || other.lastTranscription == lastTranscription)&&(identical(other.recordingsToday, recordingsToday) || other.recordingsToday == recordingsToday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastTranscription,recordingsToday);

@override
String toString() {
  return 'StatsActivity(lastTranscription: $lastTranscription, recordingsToday: $recordingsToday)';
}


}

/// @nodoc
abstract mixin class $StatsActivityCopyWith<$Res>  {
  factory $StatsActivityCopyWith(StatsActivity value, $Res Function(StatsActivity) _then) = _$StatsActivityCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate) DateTime? lastTranscription,@JsonKey(name: 'recordings_today') int? recordingsToday
});




}
/// @nodoc
class _$StatsActivityCopyWithImpl<$Res>
    implements $StatsActivityCopyWith<$Res> {
  _$StatsActivityCopyWithImpl(this._self, this._then);

  final StatsActivity _self;
  final $Res Function(StatsActivity) _then;

/// Create a copy of StatsActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastTranscription = freezed,Object? recordingsToday = freezed,}) {
  return _then(_self.copyWith(
lastTranscription: freezed == lastTranscription ? _self.lastTranscription : lastTranscription // ignore: cast_nullable_to_non_nullable
as DateTime?,recordingsToday: freezed == recordingsToday ? _self.recordingsToday : recordingsToday // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsActivity].
extension StatsActivityPatterns on StatsActivity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsActivity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsActivity value)  $default,){
final _that = this;
switch (_that) {
case _StatsActivity():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsActivity value)?  $default,){
final _that = this;
switch (_that) {
case _StatsActivity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate)  DateTime? lastTranscription, @JsonKey(name: 'recordings_today')  int? recordingsToday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsActivity() when $default != null:
return $default(_that.lastTranscription,_that.recordingsToday);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate)  DateTime? lastTranscription, @JsonKey(name: 'recordings_today')  int? recordingsToday)  $default,) {final _that = this;
switch (_that) {
case _StatsActivity():
return $default(_that.lastTranscription,_that.recordingsToday);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate)  DateTime? lastTranscription, @JsonKey(name: 'recordings_today')  int? recordingsToday)?  $default,) {final _that = this;
switch (_that) {
case _StatsActivity() when $default != null:
return $default(_that.lastTranscription,_that.recordingsToday);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsActivity implements StatsActivity {
  const _StatsActivity({@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate) this.lastTranscription, @JsonKey(name: 'recordings_today') this.recordingsToday});
  factory _StatsActivity.fromJson(Map<String, dynamic> json) => _$StatsActivityFromJson(json);

@override@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate) final  DateTime? lastTranscription;
@override@JsonKey(name: 'recordings_today') final  int? recordingsToday;

/// Create a copy of StatsActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsActivityCopyWith<_StatsActivity> get copyWith => __$StatsActivityCopyWithImpl<_StatsActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsActivity&&(identical(other.lastTranscription, lastTranscription) || other.lastTranscription == lastTranscription)&&(identical(other.recordingsToday, recordingsToday) || other.recordingsToday == recordingsToday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastTranscription,recordingsToday);

@override
String toString() {
  return 'StatsActivity(lastTranscription: $lastTranscription, recordingsToday: $recordingsToday)';
}


}

/// @nodoc
abstract mixin class _$StatsActivityCopyWith<$Res> implements $StatsActivityCopyWith<$Res> {
  factory _$StatsActivityCopyWith(_StatsActivity value, $Res Function(_StatsActivity) _then) = __$StatsActivityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate) DateTime? lastTranscription,@JsonKey(name: 'recordings_today') int? recordingsToday
});




}
/// @nodoc
class __$StatsActivityCopyWithImpl<$Res>
    implements _$StatsActivityCopyWith<$Res> {
  __$StatsActivityCopyWithImpl(this._self, this._then);

  final _StatsActivity _self;
  final $Res Function(_StatsActivity) _then;

/// Create a copy of StatsActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastTranscription = freezed,Object? recordingsToday = freezed,}) {
  return _then(_StatsActivity(
lastTranscription: freezed == lastTranscription ? _self.lastTranscription : lastTranscription // ignore: cast_nullable_to_non_nullable
as DateTime?,recordingsToday: freezed == recordingsToday ? _self.recordingsToday : recordingsToday // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StatsQueue {

@JsonKey(name: 'jobs_processing') int? get jobsProcessing;@JsonKey(name: 'jobs_queued') int? get jobsQueued;
/// Create a copy of StatsQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsQueueCopyWith<StatsQueue> get copyWith => _$StatsQueueCopyWithImpl<StatsQueue>(this as StatsQueue, _$identity);

  /// Serializes this StatsQueue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsQueue&&(identical(other.jobsProcessing, jobsProcessing) || other.jobsProcessing == jobsProcessing)&&(identical(other.jobsQueued, jobsQueued) || other.jobsQueued == jobsQueued));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobsProcessing,jobsQueued);

@override
String toString() {
  return 'StatsQueue(jobsProcessing: $jobsProcessing, jobsQueued: $jobsQueued)';
}


}

/// @nodoc
abstract mixin class $StatsQueueCopyWith<$Res>  {
  factory $StatsQueueCopyWith(StatsQueue value, $Res Function(StatsQueue) _then) = _$StatsQueueCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'jobs_processing') int? jobsProcessing,@JsonKey(name: 'jobs_queued') int? jobsQueued
});




}
/// @nodoc
class _$StatsQueueCopyWithImpl<$Res>
    implements $StatsQueueCopyWith<$Res> {
  _$StatsQueueCopyWithImpl(this._self, this._then);

  final StatsQueue _self;
  final $Res Function(StatsQueue) _then;

/// Create a copy of StatsQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobsProcessing = freezed,Object? jobsQueued = freezed,}) {
  return _then(_self.copyWith(
jobsProcessing: freezed == jobsProcessing ? _self.jobsProcessing : jobsProcessing // ignore: cast_nullable_to_non_nullable
as int?,jobsQueued: freezed == jobsQueued ? _self.jobsQueued : jobsQueued // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsQueue].
extension StatsQueuePatterns on StatsQueue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsQueue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsQueue value)  $default,){
final _that = this;
switch (_that) {
case _StatsQueue():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsQueue value)?  $default,){
final _that = this;
switch (_that) {
case _StatsQueue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'jobs_processing')  int? jobsProcessing, @JsonKey(name: 'jobs_queued')  int? jobsQueued)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsQueue() when $default != null:
return $default(_that.jobsProcessing,_that.jobsQueued);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'jobs_processing')  int? jobsProcessing, @JsonKey(name: 'jobs_queued')  int? jobsQueued)  $default,) {final _that = this;
switch (_that) {
case _StatsQueue():
return $default(_that.jobsProcessing,_that.jobsQueued);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'jobs_processing')  int? jobsProcessing, @JsonKey(name: 'jobs_queued')  int? jobsQueued)?  $default,) {final _that = this;
switch (_that) {
case _StatsQueue() when $default != null:
return $default(_that.jobsProcessing,_that.jobsQueued);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsQueue implements StatsQueue {
  const _StatsQueue({@JsonKey(name: 'jobs_processing') this.jobsProcessing, @JsonKey(name: 'jobs_queued') this.jobsQueued});
  factory _StatsQueue.fromJson(Map<String, dynamic> json) => _$StatsQueueFromJson(json);

@override@JsonKey(name: 'jobs_processing') final  int? jobsProcessing;
@override@JsonKey(name: 'jobs_queued') final  int? jobsQueued;

/// Create a copy of StatsQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsQueueCopyWith<_StatsQueue> get copyWith => __$StatsQueueCopyWithImpl<_StatsQueue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsQueueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsQueue&&(identical(other.jobsProcessing, jobsProcessing) || other.jobsProcessing == jobsProcessing)&&(identical(other.jobsQueued, jobsQueued) || other.jobsQueued == jobsQueued));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobsProcessing,jobsQueued);

@override
String toString() {
  return 'StatsQueue(jobsProcessing: $jobsProcessing, jobsQueued: $jobsQueued)';
}


}

/// @nodoc
abstract mixin class _$StatsQueueCopyWith<$Res> implements $StatsQueueCopyWith<$Res> {
  factory _$StatsQueueCopyWith(_StatsQueue value, $Res Function(_StatsQueue) _then) = __$StatsQueueCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'jobs_processing') int? jobsProcessing,@JsonKey(name: 'jobs_queued') int? jobsQueued
});




}
/// @nodoc
class __$StatsQueueCopyWithImpl<$Res>
    implements _$StatsQueueCopyWith<$Res> {
  __$StatsQueueCopyWithImpl(this._self, this._then);

  final _StatsQueue _self;
  final $Res Function(_StatsQueue) _then;

/// Create a copy of StatsQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobsProcessing = freezed,Object? jobsQueued = freezed,}) {
  return _then(_StatsQueue(
jobsProcessing: freezed == jobsProcessing ? _self.jobsProcessing : jobsProcessing // ignore: cast_nullable_to_non_nullable
as int?,jobsQueued: freezed == jobsQueued ? _self.jobsQueued : jobsQueued // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StatsRecordings {

 int? get completed; int? get failed; int? get pending; int? get processing; int? get total;
/// Create a copy of StatsRecordings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsRecordingsCopyWith<StatsRecordings> get copyWith => _$StatsRecordingsCopyWithImpl<StatsRecordings>(this as StatsRecordings, _$identity);

  /// Serializes this StatsRecordings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsRecordings&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.processing, processing) || other.processing == processing)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,failed,pending,processing,total);

@override
String toString() {
  return 'StatsRecordings(completed: $completed, failed: $failed, pending: $pending, processing: $processing, total: $total)';
}


}

/// @nodoc
abstract mixin class $StatsRecordingsCopyWith<$Res>  {
  factory $StatsRecordingsCopyWith(StatsRecordings value, $Res Function(StatsRecordings) _then) = _$StatsRecordingsCopyWithImpl;
@useResult
$Res call({
 int? completed, int? failed, int? pending, int? processing, int? total
});




}
/// @nodoc
class _$StatsRecordingsCopyWithImpl<$Res>
    implements $StatsRecordingsCopyWith<$Res> {
  _$StatsRecordingsCopyWithImpl(this._self, this._then);

  final StatsRecordings _self;
  final $Res Function(StatsRecordings) _then;

/// Create a copy of StatsRecordings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completed = freezed,Object? failed = freezed,Object? pending = freezed,Object? processing = freezed,Object? total = freezed,}) {
  return _then(_self.copyWith(
completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int?,failed: freezed == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int?,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int?,processing: freezed == processing ? _self.processing : processing // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsRecordings].
extension StatsRecordingsPatterns on StatsRecordings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsRecordings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsRecordings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsRecordings value)  $default,){
final _that = this;
switch (_that) {
case _StatsRecordings():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsRecordings value)?  $default,){
final _that = this;
switch (_that) {
case _StatsRecordings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? completed,  int? failed,  int? pending,  int? processing,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsRecordings() when $default != null:
return $default(_that.completed,_that.failed,_that.pending,_that.processing,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? completed,  int? failed,  int? pending,  int? processing,  int? total)  $default,) {final _that = this;
switch (_that) {
case _StatsRecordings():
return $default(_that.completed,_that.failed,_that.pending,_that.processing,_that.total);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? completed,  int? failed,  int? pending,  int? processing,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _StatsRecordings() when $default != null:
return $default(_that.completed,_that.failed,_that.pending,_that.processing,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsRecordings implements StatsRecordings {
  const _StatsRecordings({this.completed, this.failed, this.pending, this.processing, this.total});
  factory _StatsRecordings.fromJson(Map<String, dynamic> json) => _$StatsRecordingsFromJson(json);

@override final  int? completed;
@override final  int? failed;
@override final  int? pending;
@override final  int? processing;
@override final  int? total;

/// Create a copy of StatsRecordings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsRecordingsCopyWith<_StatsRecordings> get copyWith => __$StatsRecordingsCopyWithImpl<_StatsRecordings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsRecordingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsRecordings&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.processing, processing) || other.processing == processing)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,failed,pending,processing,total);

@override
String toString() {
  return 'StatsRecordings(completed: $completed, failed: $failed, pending: $pending, processing: $processing, total: $total)';
}


}

/// @nodoc
abstract mixin class _$StatsRecordingsCopyWith<$Res> implements $StatsRecordingsCopyWith<$Res> {
  factory _$StatsRecordingsCopyWith(_StatsRecordings value, $Res Function(_StatsRecordings) _then) = __$StatsRecordingsCopyWithImpl;
@override @useResult
$Res call({
 int? completed, int? failed, int? pending, int? processing, int? total
});




}
/// @nodoc
class __$StatsRecordingsCopyWithImpl<$Res>
    implements _$StatsRecordingsCopyWith<$Res> {
  __$StatsRecordingsCopyWithImpl(this._self, this._then);

  final _StatsRecordings _self;
  final $Res Function(_StatsRecordings) _then;

/// Create a copy of StatsRecordings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completed = freezed,Object? failed = freezed,Object? pending = freezed,Object? processing = freezed,Object? total = freezed,}) {
  return _then(_StatsRecordings(
completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int?,failed: freezed == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int?,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int?,processing: freezed == processing ? _self.processing : processing // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StatsStorage {

@JsonKey(name: 'used_bytes') int? get usedBytes;@JsonKey(name: 'used_human') String? get usedHuman;
/// Create a copy of StatsStorage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsStorageCopyWith<StatsStorage> get copyWith => _$StatsStorageCopyWithImpl<StatsStorage>(this as StatsStorage, _$identity);

  /// Serializes this StatsStorage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsStorage&&(identical(other.usedBytes, usedBytes) || other.usedBytes == usedBytes)&&(identical(other.usedHuman, usedHuman) || other.usedHuman == usedHuman));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usedBytes,usedHuman);

@override
String toString() {
  return 'StatsStorage(usedBytes: $usedBytes, usedHuman: $usedHuman)';
}


}

/// @nodoc
abstract mixin class $StatsStorageCopyWith<$Res>  {
  factory $StatsStorageCopyWith(StatsStorage value, $Res Function(StatsStorage) _then) = _$StatsStorageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'used_bytes') int? usedBytes,@JsonKey(name: 'used_human') String? usedHuman
});




}
/// @nodoc
class _$StatsStorageCopyWithImpl<$Res>
    implements $StatsStorageCopyWith<$Res> {
  _$StatsStorageCopyWithImpl(this._self, this._then);

  final StatsStorage _self;
  final $Res Function(StatsStorage) _then;

/// Create a copy of StatsStorage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usedBytes = freezed,Object? usedHuman = freezed,}) {
  return _then(_self.copyWith(
usedBytes: freezed == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int?,usedHuman: freezed == usedHuman ? _self.usedHuman : usedHuman // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsStorage].
extension StatsStoragePatterns on StatsStorage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsStorage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsStorage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsStorage value)  $default,){
final _that = this;
switch (_that) {
case _StatsStorage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsStorage value)?  $default,){
final _that = this;
switch (_that) {
case _StatsStorage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'used_bytes')  int? usedBytes, @JsonKey(name: 'used_human')  String? usedHuman)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsStorage() when $default != null:
return $default(_that.usedBytes,_that.usedHuman);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'used_bytes')  int? usedBytes, @JsonKey(name: 'used_human')  String? usedHuman)  $default,) {final _that = this;
switch (_that) {
case _StatsStorage():
return $default(_that.usedBytes,_that.usedHuman);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'used_bytes')  int? usedBytes, @JsonKey(name: 'used_human')  String? usedHuman)?  $default,) {final _that = this;
switch (_that) {
case _StatsStorage() when $default != null:
return $default(_that.usedBytes,_that.usedHuman);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsStorage implements StatsStorage {
  const _StatsStorage({@JsonKey(name: 'used_bytes') this.usedBytes, @JsonKey(name: 'used_human') this.usedHuman});
  factory _StatsStorage.fromJson(Map<String, dynamic> json) => _$StatsStorageFromJson(json);

@override@JsonKey(name: 'used_bytes') final  int? usedBytes;
@override@JsonKey(name: 'used_human') final  String? usedHuman;

/// Create a copy of StatsStorage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsStorageCopyWith<_StatsStorage> get copyWith => __$StatsStorageCopyWithImpl<_StatsStorage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsStorageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsStorage&&(identical(other.usedBytes, usedBytes) || other.usedBytes == usedBytes)&&(identical(other.usedHuman, usedHuman) || other.usedHuman == usedHuman));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usedBytes,usedHuman);

@override
String toString() {
  return 'StatsStorage(usedBytes: $usedBytes, usedHuman: $usedHuman)';
}


}

/// @nodoc
abstract mixin class _$StatsStorageCopyWith<$Res> implements $StatsStorageCopyWith<$Res> {
  factory _$StatsStorageCopyWith(_StatsStorage value, $Res Function(_StatsStorage) _then) = __$StatsStorageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'used_bytes') int? usedBytes,@JsonKey(name: 'used_human') String? usedHuman
});




}
/// @nodoc
class __$StatsStorageCopyWithImpl<$Res>
    implements _$StatsStorageCopyWith<$Res> {
  __$StatsStorageCopyWithImpl(this._self, this._then);

  final _StatsStorage _self;
  final $Res Function(_StatsStorage) _then;

/// Create a copy of StatsStorage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usedBytes = freezed,Object? usedHuman = freezed,}) {
  return _then(_StatsStorage(
usedBytes: freezed == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int?,usedHuman: freezed == usedHuman ? _self.usedHuman : usedHuman // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StatsTokens {

 int? get budget; double? get percentage;@JsonKey(name: 'used_this_month') int? get usedThisMonth;
/// Create a copy of StatsTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsTokensCopyWith<StatsTokens> get copyWith => _$StatsTokensCopyWithImpl<StatsTokens>(this as StatsTokens, _$identity);

  /// Serializes this StatsTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsTokens&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.usedThisMonth, usedThisMonth) || other.usedThisMonth == usedThisMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budget,percentage,usedThisMonth);

@override
String toString() {
  return 'StatsTokens(budget: $budget, percentage: $percentage, usedThisMonth: $usedThisMonth)';
}


}

/// @nodoc
abstract mixin class $StatsTokensCopyWith<$Res>  {
  factory $StatsTokensCopyWith(StatsTokens value, $Res Function(StatsTokens) _then) = _$StatsTokensCopyWithImpl;
@useResult
$Res call({
 int? budget, double? percentage,@JsonKey(name: 'used_this_month') int? usedThisMonth
});




}
/// @nodoc
class _$StatsTokensCopyWithImpl<$Res>
    implements $StatsTokensCopyWith<$Res> {
  _$StatsTokensCopyWithImpl(this._self, this._then);

  final StatsTokens _self;
  final $Res Function(StatsTokens) _then;

/// Create a copy of StatsTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budget = freezed,Object? percentage = freezed,Object? usedThisMonth = freezed,}) {
  return _then(_self.copyWith(
budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,usedThisMonth: freezed == usedThisMonth ? _self.usedThisMonth : usedThisMonth // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsTokens].
extension StatsTokensPatterns on StatsTokens {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsTokens() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsTokens value)  $default,){
final _that = this;
switch (_that) {
case _StatsTokens():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsTokens value)?  $default,){
final _that = this;
switch (_that) {
case _StatsTokens() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? budget,  double? percentage, @JsonKey(name: 'used_this_month')  int? usedThisMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsTokens() when $default != null:
return $default(_that.budget,_that.percentage,_that.usedThisMonth);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? budget,  double? percentage, @JsonKey(name: 'used_this_month')  int? usedThisMonth)  $default,) {final _that = this;
switch (_that) {
case _StatsTokens():
return $default(_that.budget,_that.percentage,_that.usedThisMonth);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? budget,  double? percentage, @JsonKey(name: 'used_this_month')  int? usedThisMonth)?  $default,) {final _that = this;
switch (_that) {
case _StatsTokens() when $default != null:
return $default(_that.budget,_that.percentage,_that.usedThisMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsTokens implements StatsTokens {
  const _StatsTokens({this.budget, this.percentage, @JsonKey(name: 'used_this_month') this.usedThisMonth});
  factory _StatsTokens.fromJson(Map<String, dynamic> json) => _$StatsTokensFromJson(json);

@override final  int? budget;
@override final  double? percentage;
@override@JsonKey(name: 'used_this_month') final  int? usedThisMonth;

/// Create a copy of StatsTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsTokensCopyWith<_StatsTokens> get copyWith => __$StatsTokensCopyWithImpl<_StatsTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsTokensToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsTokens&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.usedThisMonth, usedThisMonth) || other.usedThisMonth == usedThisMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budget,percentage,usedThisMonth);

@override
String toString() {
  return 'StatsTokens(budget: $budget, percentage: $percentage, usedThisMonth: $usedThisMonth)';
}


}

/// @nodoc
abstract mixin class _$StatsTokensCopyWith<$Res> implements $StatsTokensCopyWith<$Res> {
  factory _$StatsTokensCopyWith(_StatsTokens value, $Res Function(_StatsTokens) _then) = __$StatsTokensCopyWithImpl;
@override @useResult
$Res call({
 int? budget, double? percentage,@JsonKey(name: 'used_this_month') int? usedThisMonth
});




}
/// @nodoc
class __$StatsTokensCopyWithImpl<$Res>
    implements _$StatsTokensCopyWith<$Res> {
  __$StatsTokensCopyWithImpl(this._self, this._then);

  final _StatsTokens _self;
  final $Res Function(_StatsTokens) _then;

/// Create a copy of StatsTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budget = freezed,Object? percentage = freezed,Object? usedThisMonth = freezed,}) {
  return _then(_StatsTokens(
budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,usedThisMonth: freezed == usedThisMonth ? _self.usedThisMonth : usedThisMonth // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StatsTranscription {

@JsonKey(name: 'budget_minutes') int? get budgetMinutes;@JsonKey(name: 'budget_seconds') int? get budgetSeconds;@JsonKey(name: 'estimated_cost') double? get estimatedCost; double? get percentage;@JsonKey(name: 'used_this_month_minutes') int? get usedThisMonthMinutes;@JsonKey(name: 'used_this_month_seconds') int? get usedThisMonthSeconds;
/// Create a copy of StatsTranscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsTranscriptionCopyWith<StatsTranscription> get copyWith => _$StatsTranscriptionCopyWithImpl<StatsTranscription>(this as StatsTranscription, _$identity);

  /// Serializes this StatsTranscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsTranscription&&(identical(other.budgetMinutes, budgetMinutes) || other.budgetMinutes == budgetMinutes)&&(identical(other.budgetSeconds, budgetSeconds) || other.budgetSeconds == budgetSeconds)&&(identical(other.estimatedCost, estimatedCost) || other.estimatedCost == estimatedCost)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.usedThisMonthMinutes, usedThisMonthMinutes) || other.usedThisMonthMinutes == usedThisMonthMinutes)&&(identical(other.usedThisMonthSeconds, usedThisMonthSeconds) || other.usedThisMonthSeconds == usedThisMonthSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budgetMinutes,budgetSeconds,estimatedCost,percentage,usedThisMonthMinutes,usedThisMonthSeconds);

@override
String toString() {
  return 'StatsTranscription(budgetMinutes: $budgetMinutes, budgetSeconds: $budgetSeconds, estimatedCost: $estimatedCost, percentage: $percentage, usedThisMonthMinutes: $usedThisMonthMinutes, usedThisMonthSeconds: $usedThisMonthSeconds)';
}


}

/// @nodoc
abstract mixin class $StatsTranscriptionCopyWith<$Res>  {
  factory $StatsTranscriptionCopyWith(StatsTranscription value, $Res Function(StatsTranscription) _then) = _$StatsTranscriptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'budget_minutes') int? budgetMinutes,@JsonKey(name: 'budget_seconds') int? budgetSeconds,@JsonKey(name: 'estimated_cost') double? estimatedCost, double? percentage,@JsonKey(name: 'used_this_month_minutes') int? usedThisMonthMinutes,@JsonKey(name: 'used_this_month_seconds') int? usedThisMonthSeconds
});




}
/// @nodoc
class _$StatsTranscriptionCopyWithImpl<$Res>
    implements $StatsTranscriptionCopyWith<$Res> {
  _$StatsTranscriptionCopyWithImpl(this._self, this._then);

  final StatsTranscription _self;
  final $Res Function(StatsTranscription) _then;

/// Create a copy of StatsTranscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budgetMinutes = freezed,Object? budgetSeconds = freezed,Object? estimatedCost = freezed,Object? percentage = freezed,Object? usedThisMonthMinutes = freezed,Object? usedThisMonthSeconds = freezed,}) {
  return _then(_self.copyWith(
budgetMinutes: freezed == budgetMinutes ? _self.budgetMinutes : budgetMinutes // ignore: cast_nullable_to_non_nullable
as int?,budgetSeconds: freezed == budgetSeconds ? _self.budgetSeconds : budgetSeconds // ignore: cast_nullable_to_non_nullable
as int?,estimatedCost: freezed == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,usedThisMonthMinutes: freezed == usedThisMonthMinutes ? _self.usedThisMonthMinutes : usedThisMonthMinutes // ignore: cast_nullable_to_non_nullable
as int?,usedThisMonthSeconds: freezed == usedThisMonthSeconds ? _self.usedThisMonthSeconds : usedThisMonthSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsTranscription].
extension StatsTranscriptionPatterns on StatsTranscription {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsTranscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsTranscription() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsTranscription value)  $default,){
final _that = this;
switch (_that) {
case _StatsTranscription():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsTranscription value)?  $default,){
final _that = this;
switch (_that) {
case _StatsTranscription() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'budget_minutes')  int? budgetMinutes, @JsonKey(name: 'budget_seconds')  int? budgetSeconds, @JsonKey(name: 'estimated_cost')  double? estimatedCost,  double? percentage, @JsonKey(name: 'used_this_month_minutes')  int? usedThisMonthMinutes, @JsonKey(name: 'used_this_month_seconds')  int? usedThisMonthSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsTranscription() when $default != null:
return $default(_that.budgetMinutes,_that.budgetSeconds,_that.estimatedCost,_that.percentage,_that.usedThisMonthMinutes,_that.usedThisMonthSeconds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'budget_minutes')  int? budgetMinutes, @JsonKey(name: 'budget_seconds')  int? budgetSeconds, @JsonKey(name: 'estimated_cost')  double? estimatedCost,  double? percentage, @JsonKey(name: 'used_this_month_minutes')  int? usedThisMonthMinutes, @JsonKey(name: 'used_this_month_seconds')  int? usedThisMonthSeconds)  $default,) {final _that = this;
switch (_that) {
case _StatsTranscription():
return $default(_that.budgetMinutes,_that.budgetSeconds,_that.estimatedCost,_that.percentage,_that.usedThisMonthMinutes,_that.usedThisMonthSeconds);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'budget_minutes')  int? budgetMinutes, @JsonKey(name: 'budget_seconds')  int? budgetSeconds, @JsonKey(name: 'estimated_cost')  double? estimatedCost,  double? percentage, @JsonKey(name: 'used_this_month_minutes')  int? usedThisMonthMinutes, @JsonKey(name: 'used_this_month_seconds')  int? usedThisMonthSeconds)?  $default,) {final _that = this;
switch (_that) {
case _StatsTranscription() when $default != null:
return $default(_that.budgetMinutes,_that.budgetSeconds,_that.estimatedCost,_that.percentage,_that.usedThisMonthMinutes,_that.usedThisMonthSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsTranscription implements StatsTranscription {
  const _StatsTranscription({@JsonKey(name: 'budget_minutes') this.budgetMinutes, @JsonKey(name: 'budget_seconds') this.budgetSeconds, @JsonKey(name: 'estimated_cost') this.estimatedCost, this.percentage, @JsonKey(name: 'used_this_month_minutes') this.usedThisMonthMinutes, @JsonKey(name: 'used_this_month_seconds') this.usedThisMonthSeconds});
  factory _StatsTranscription.fromJson(Map<String, dynamic> json) => _$StatsTranscriptionFromJson(json);

@override@JsonKey(name: 'budget_minutes') final  int? budgetMinutes;
@override@JsonKey(name: 'budget_seconds') final  int? budgetSeconds;
@override@JsonKey(name: 'estimated_cost') final  double? estimatedCost;
@override final  double? percentage;
@override@JsonKey(name: 'used_this_month_minutes') final  int? usedThisMonthMinutes;
@override@JsonKey(name: 'used_this_month_seconds') final  int? usedThisMonthSeconds;

/// Create a copy of StatsTranscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsTranscriptionCopyWith<_StatsTranscription> get copyWith => __$StatsTranscriptionCopyWithImpl<_StatsTranscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsTranscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsTranscription&&(identical(other.budgetMinutes, budgetMinutes) || other.budgetMinutes == budgetMinutes)&&(identical(other.budgetSeconds, budgetSeconds) || other.budgetSeconds == budgetSeconds)&&(identical(other.estimatedCost, estimatedCost) || other.estimatedCost == estimatedCost)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.usedThisMonthMinutes, usedThisMonthMinutes) || other.usedThisMonthMinutes == usedThisMonthMinutes)&&(identical(other.usedThisMonthSeconds, usedThisMonthSeconds) || other.usedThisMonthSeconds == usedThisMonthSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,budgetMinutes,budgetSeconds,estimatedCost,percentage,usedThisMonthMinutes,usedThisMonthSeconds);

@override
String toString() {
  return 'StatsTranscription(budgetMinutes: $budgetMinutes, budgetSeconds: $budgetSeconds, estimatedCost: $estimatedCost, percentage: $percentage, usedThisMonthMinutes: $usedThisMonthMinutes, usedThisMonthSeconds: $usedThisMonthSeconds)';
}


}

/// @nodoc
abstract mixin class _$StatsTranscriptionCopyWith<$Res> implements $StatsTranscriptionCopyWith<$Res> {
  factory _$StatsTranscriptionCopyWith(_StatsTranscription value, $Res Function(_StatsTranscription) _then) = __$StatsTranscriptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'budget_minutes') int? budgetMinutes,@JsonKey(name: 'budget_seconds') int? budgetSeconds,@JsonKey(name: 'estimated_cost') double? estimatedCost, double? percentage,@JsonKey(name: 'used_this_month_minutes') int? usedThisMonthMinutes,@JsonKey(name: 'used_this_month_seconds') int? usedThisMonthSeconds
});




}
/// @nodoc
class __$StatsTranscriptionCopyWithImpl<$Res>
    implements _$StatsTranscriptionCopyWith<$Res> {
  __$StatsTranscriptionCopyWithImpl(this._self, this._then);

  final _StatsTranscription _self;
  final $Res Function(_StatsTranscription) _then;

/// Create a copy of StatsTranscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budgetMinutes = freezed,Object? budgetSeconds = freezed,Object? estimatedCost = freezed,Object? percentage = freezed,Object? usedThisMonthMinutes = freezed,Object? usedThisMonthSeconds = freezed,}) {
  return _then(_StatsTranscription(
budgetMinutes: freezed == budgetMinutes ? _self.budgetMinutes : budgetMinutes // ignore: cast_nullable_to_non_nullable
as int?,budgetSeconds: freezed == budgetSeconds ? _self.budgetSeconds : budgetSeconds // ignore: cast_nullable_to_non_nullable
as int?,estimatedCost: freezed == estimatedCost ? _self.estimatedCost : estimatedCost // ignore: cast_nullable_to_non_nullable
as double?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,usedThisMonthMinutes: freezed == usedThisMonthMinutes ? _self.usedThisMonthMinutes : usedThisMonthMinutes // ignore: cast_nullable_to_non_nullable
as int?,usedThisMonthSeconds: freezed == usedThisMonthSeconds ? _self.usedThisMonthSeconds : usedThisMonthSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
