// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_network.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NetworkStatus {

/// Whether the device has a connection.
 bool get deviceOnline;/// Whether the demo switch says "offline" anyway.
 bool get simulatingOffline;
/// Create a copy of NetworkStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkStatusCopyWith<NetworkStatus> get copyWith => _$NetworkStatusCopyWithImpl<NetworkStatus>(this as NetworkStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NetworkStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkStatus&&(identical(other.deviceOnline, _this.deviceOnline) || other.deviceOnline == _this.deviceOnline)&&(identical(other.simulatingOffline, _this.simulatingOffline) || other.simulatingOffline == _this.simulatingOffline));
}


@override
int get hashCode {
  final _this = this as NetworkStatus;
  return Object.hash(runtimeType,_this.deviceOnline,_this.simulatingOffline);
}

@override
String toString() {
  final _this = this as NetworkStatus;
  return 'NetworkStatus(deviceOnline: ${_this.deviceOnline}, simulatingOffline: ${_this.simulatingOffline})';
}


}

/// @nodoc
abstract mixin class $NetworkStatusCopyWith<$Res>  {
  factory $NetworkStatusCopyWith(NetworkStatus value, $Res Function(NetworkStatus) _then) = _$NetworkStatusCopyWithImpl;
@useResult
$Res call({
 bool deviceOnline, bool simulatingOffline
});




}
/// @nodoc
class _$NetworkStatusCopyWithImpl<$Res>
    implements $NetworkStatusCopyWith<$Res> {
  _$NetworkStatusCopyWithImpl(this._self, this._then);

  final NetworkStatus _self;
  final $Res Function(NetworkStatus) _then;

/// Create a copy of NetworkStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceOnline = null,Object? simulatingOffline = null,}) {
  return _then(NetworkStatus(
deviceOnline: null == deviceOnline ? _self.deviceOnline : deviceOnline // ignore: cast_nullable_to_non_nullable
as bool,simulatingOffline: null == simulatingOffline ? _self.simulatingOffline : simulatingOffline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkStatus].
extension NetworkStatusPatterns on NetworkStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkStatus value)  $default,){
final _that = this;
switch (_that) {
case _NetworkStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkStatus value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool deviceOnline,  bool simulatingOffline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkStatus() when $default != null:
return $default(_that.deviceOnline,_that.simulatingOffline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool deviceOnline,  bool simulatingOffline)  $default,) {final _that = this;
switch (_that) {
case _NetworkStatus():
return $default(_that.deviceOnline,_that.simulatingOffline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool deviceOnline,  bool simulatingOffline)?  $default,) {final _that = this;
switch (_that) {
case _NetworkStatus() when $default != null:
return $default(_that.deviceOnline,_that.simulatingOffline);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkStatus extends NetworkStatus {
  const _NetworkStatus({required this.deviceOnline, this.simulatingOffline = false}): super._();
  

/// Whether the device has a connection.
@override final  bool deviceOnline;
/// Whether the demo switch says "offline" anyway.
@override@JsonKey() final  bool simulatingOffline;

/// Create a copy of NetworkStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkStatusCopyWith<_NetworkStatus> get copyWith => __$NetworkStatusCopyWithImpl<_NetworkStatus>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkStatus&&(identical(other.deviceOnline, deviceOnline) || other.deviceOnline == deviceOnline)&&(identical(other.simulatingOffline, simulatingOffline) || other.simulatingOffline == simulatingOffline));
}


@override
int get hashCode {
    return Object.hash(runtimeType,deviceOnline,simulatingOffline);
}

@override
String toString() {
    return 'NetworkStatus(deviceOnline: $deviceOnline, simulatingOffline: $simulatingOffline)';
}


}

/// @nodoc
abstract mixin class _$NetworkStatusCopyWith<$Res> implements $NetworkStatusCopyWith<$Res> {
  factory _$NetworkStatusCopyWith(_NetworkStatus value, $Res Function(_NetworkStatus) _then) = __$NetworkStatusCopyWithImpl;
@override @useResult
$Res call({
 bool deviceOnline, bool simulatingOffline
});




}
/// @nodoc
class __$NetworkStatusCopyWithImpl<$Res>
    implements _$NetworkStatusCopyWith<$Res> {
  __$NetworkStatusCopyWithImpl(this._self, this._then);

  final _NetworkStatus _self;
  final $Res Function(_NetworkStatus) _then;

/// Create a copy of NetworkStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceOnline = null,Object? simulatingOffline = null,}) {
  return _then(_NetworkStatus(
deviceOnline: null == deviceOnline ? _self.deviceOnline : deviceOnline // ignore: cast_nullable_to_non_nullable
as bool,simulatingOffline: null == simulatingOffline ? _self.simulatingOffline : simulatingOffline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
