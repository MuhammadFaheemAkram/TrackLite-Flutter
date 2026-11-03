// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsIdentity {

 String get anonymousId;/// The signed-in user, if any.
 String? get userId;
/// Create a copy of AnalyticsIdentity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsIdentityCopyWith<AnalyticsIdentity> get copyWith => _$AnalyticsIdentityCopyWithImpl<AnalyticsIdentity>(this as AnalyticsIdentity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsIdentity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsIdentity&&(identical(other.anonymousId, _this.anonymousId) || other.anonymousId == _this.anonymousId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId));
}


@override
int get hashCode {
  final _this = this as AnalyticsIdentity;
  return Object.hash(runtimeType,_this.anonymousId,_this.userId);
}

@override
String toString() {
  final _this = this as AnalyticsIdentity;
  return 'AnalyticsIdentity(anonymousId: ${_this.anonymousId}, userId: ${_this.userId})';
}


}

/// @nodoc
abstract mixin class $AnalyticsIdentityCopyWith<$Res>  {
  factory $AnalyticsIdentityCopyWith(AnalyticsIdentity value, $Res Function(AnalyticsIdentity) _then) = _$AnalyticsIdentityCopyWithImpl;
@useResult
$Res call({
 String anonymousId, String? userId
});




}
/// @nodoc
class _$AnalyticsIdentityCopyWithImpl<$Res>
    implements $AnalyticsIdentityCopyWith<$Res> {
  _$AnalyticsIdentityCopyWithImpl(this._self, this._then);

  final AnalyticsIdentity _self;
  final $Res Function(AnalyticsIdentity) _then;

/// Create a copy of AnalyticsIdentity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? anonymousId = null,Object? userId = freezed,}) {
  return _then(AnalyticsIdentity(
anonymousId: null == anonymousId ? _self.anonymousId : anonymousId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsIdentity].
extension AnalyticsIdentityPatterns on AnalyticsIdentity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsIdentity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsIdentity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsIdentity value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsIdentity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsIdentity value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsIdentity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String anonymousId,  String? userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsIdentity() when $default != null:
return $default(_that.anonymousId,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String anonymousId,  String? userId)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsIdentity():
return $default(_that.anonymousId,_that.userId);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String anonymousId,  String? userId)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsIdentity() when $default != null:
return $default(_that.anonymousId,_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsIdentity implements AnalyticsIdentity {
  const _AnalyticsIdentity({required this.anonymousId, this.userId});
  

@override final  String anonymousId;
/// The signed-in user, if any.
@override final  String? userId;

/// Create a copy of AnalyticsIdentity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsIdentityCopyWith<_AnalyticsIdentity> get copyWith => __$AnalyticsIdentityCopyWithImpl<_AnalyticsIdentity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsIdentity&&(identical(other.anonymousId, anonymousId) || other.anonymousId == anonymousId)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,anonymousId,userId);
}

@override
String toString() {
    return 'AnalyticsIdentity(anonymousId: $anonymousId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsIdentityCopyWith<$Res> implements $AnalyticsIdentityCopyWith<$Res> {
  factory _$AnalyticsIdentityCopyWith(_AnalyticsIdentity value, $Res Function(_AnalyticsIdentity) _then) = __$AnalyticsIdentityCopyWithImpl;
@override @useResult
$Res call({
 String anonymousId, String? userId
});




}
/// @nodoc
class __$AnalyticsIdentityCopyWithImpl<$Res>
    implements _$AnalyticsIdentityCopyWith<$Res> {
  __$AnalyticsIdentityCopyWithImpl(this._self, this._then);

  final _AnalyticsIdentity _self;
  final $Res Function(_AnalyticsIdentity) _then;

/// Create a copy of AnalyticsIdentity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? anonymousId = null,Object? userId = freezed,}) {
  return _then(_AnalyticsIdentity(
anonymousId: null == anonymousId ? _self.anonymousId : anonymousId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
