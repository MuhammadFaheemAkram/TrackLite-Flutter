// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'demo_backend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DemoServerState {

 ServerFailures get failures; ServerSpeed get speed; int get requests; int get accepted; int get duplicates; int get serverFailures;
/// Create a copy of DemoServerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DemoServerStateCopyWith<DemoServerState> get copyWith => _$DemoServerStateCopyWithImpl<DemoServerState>(this as DemoServerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DemoServerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DemoServerState&&(identical(other.failures, _this.failures) || other.failures == _this.failures)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.requests, _this.requests) || other.requests == _this.requests)&&(identical(other.accepted, _this.accepted) || other.accepted == _this.accepted)&&(identical(other.duplicates, _this.duplicates) || other.duplicates == _this.duplicates)&&(identical(other.serverFailures, _this.serverFailures) || other.serverFailures == _this.serverFailures));
}


@override
int get hashCode {
  final _this = this as DemoServerState;
  return Object.hash(runtimeType,_this.failures,_this.speed,_this.requests,_this.accepted,_this.duplicates,_this.serverFailures);
}

@override
String toString() {
  final _this = this as DemoServerState;
  return 'DemoServerState(failures: ${_this.failures}, speed: ${_this.speed}, requests: ${_this.requests}, accepted: ${_this.accepted}, duplicates: ${_this.duplicates}, serverFailures: ${_this.serverFailures})';
}


}

/// @nodoc
abstract mixin class $DemoServerStateCopyWith<$Res>  {
  factory $DemoServerStateCopyWith(DemoServerState value, $Res Function(DemoServerState) _then) = _$DemoServerStateCopyWithImpl;
@useResult
$Res call({
 ServerFailures failures, ServerSpeed speed, int requests, int accepted, int duplicates, int serverFailures
});




}
/// @nodoc
class _$DemoServerStateCopyWithImpl<$Res>
    implements $DemoServerStateCopyWith<$Res> {
  _$DemoServerStateCopyWithImpl(this._self, this._then);

  final DemoServerState _self;
  final $Res Function(DemoServerState) _then;

/// Create a copy of DemoServerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? failures = null,Object? speed = null,Object? requests = null,Object? accepted = null,Object? duplicates = null,Object? serverFailures = null,}) {
  return _then(DemoServerState(
failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as ServerFailures,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as ServerSpeed,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,serverFailures: null == serverFailures ? _self.serverFailures : serverFailures // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DemoServerState].
extension DemoServerStatePatterns on DemoServerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DemoServerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DemoServerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DemoServerState value)  $default,){
final _that = this;
switch (_that) {
case _DemoServerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DemoServerState value)?  $default,){
final _that = this;
switch (_that) {
case _DemoServerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServerFailures failures,  ServerSpeed speed,  int requests,  int accepted,  int duplicates,  int serverFailures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DemoServerState() when $default != null:
return $default(_that.failures,_that.speed,_that.requests,_that.accepted,_that.duplicates,_that.serverFailures);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServerFailures failures,  ServerSpeed speed,  int requests,  int accepted,  int duplicates,  int serverFailures)  $default,) {final _that = this;
switch (_that) {
case _DemoServerState():
return $default(_that.failures,_that.speed,_that.requests,_that.accepted,_that.duplicates,_that.serverFailures);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServerFailures failures,  ServerSpeed speed,  int requests,  int accepted,  int duplicates,  int serverFailures)?  $default,) {final _that = this;
switch (_that) {
case _DemoServerState() when $default != null:
return $default(_that.failures,_that.speed,_that.requests,_that.accepted,_that.duplicates,_that.serverFailures);case _:
  return null;

}
}

}

/// @nodoc


class _DemoServerState implements DemoServerState {
  const _DemoServerState({required this.failures, required this.speed, this.requests = 0, this.accepted = 0, this.duplicates = 0, this.serverFailures = 0});
  

@override final  ServerFailures failures;
@override final  ServerSpeed speed;
@override@JsonKey() final  int requests;
@override@JsonKey() final  int accepted;
@override@JsonKey() final  int duplicates;
@override@JsonKey() final  int serverFailures;

/// Create a copy of DemoServerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoServerStateCopyWith<_DemoServerState> get copyWith => __$DemoServerStateCopyWithImpl<_DemoServerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoServerState&&(identical(other.failures, failures) || other.failures == failures)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.duplicates, duplicates) || other.duplicates == duplicates)&&(identical(other.serverFailures, serverFailures) || other.serverFailures == serverFailures));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failures,speed,requests,accepted,duplicates,serverFailures);
}

@override
String toString() {
    return 'DemoServerState(failures: $failures, speed: $speed, requests: $requests, accepted: $accepted, duplicates: $duplicates, serverFailures: $serverFailures)';
}


}

/// @nodoc
abstract mixin class _$DemoServerStateCopyWith<$Res> implements $DemoServerStateCopyWith<$Res> {
  factory _$DemoServerStateCopyWith(_DemoServerState value, $Res Function(_DemoServerState) _then) = __$DemoServerStateCopyWithImpl;
@override @useResult
$Res call({
 ServerFailures failures, ServerSpeed speed, int requests, int accepted, int duplicates, int serverFailures
});




}
/// @nodoc
class __$DemoServerStateCopyWithImpl<$Res>
    implements _$DemoServerStateCopyWith<$Res> {
  __$DemoServerStateCopyWithImpl(this._self, this._then);

  final _DemoServerState _self;
  final $Res Function(_DemoServerState) _then;

/// Create a copy of DemoServerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failures = null,Object? speed = null,Object? requests = null,Object? accepted = null,Object? duplicates = null,Object? serverFailures = null,}) {
  return _then(_DemoServerState(
failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as ServerFailures,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as ServerSpeed,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,serverFailures: null == serverFailures ? _self.serverFailures : serverFailures // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
