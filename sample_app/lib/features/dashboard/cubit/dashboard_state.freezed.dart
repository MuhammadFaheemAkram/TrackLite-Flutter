// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

/// `null` until the first snapshot arrives.
 QueueStats? get queue;/// A flush is running (the button waits for it).
 bool get flushing;/// The last flush's outcome, shown once; [flushSerial] makes a repeat
/// show again.
 FlushOutcome? get lastFlush; int get flushSerial;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.queue, _this.queue) || other.queue == _this.queue)&&(identical(other.flushing, _this.flushing) || other.flushing == _this.flushing)&&(identical(other.lastFlush, _this.lastFlush) || other.lastFlush == _this.lastFlush)&&(identical(other.flushSerial, _this.flushSerial) || other.flushSerial == _this.flushSerial));
}


@override
int get hashCode {
  final _this = this as DashboardState;
  return Object.hash(runtimeType,_this.queue,_this.flushing,_this.lastFlush,_this.flushSerial);
}

@override
String toString() {
  final _this = this as DashboardState;
  return 'DashboardState(queue: ${_this.queue}, flushing: ${_this.flushing}, lastFlush: ${_this.lastFlush}, flushSerial: ${_this.flushSerial})';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 QueueStats? queue, bool flushing, FlushOutcome? lastFlush, int flushSerial
});


$QueueStatsCopyWith<$Res>? get queue;$FlushOutcomeCopyWith<$Res>? get lastFlush;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = freezed,Object? flushing = null,Object? lastFlush = freezed,Object? flushSerial = null,}) {
  return _then(DashboardState(
queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as QueueStats?,flushing: null == flushing ? _self.flushing : flushing // ignore: cast_nullable_to_non_nullable
as bool,lastFlush: freezed == lastFlush ? _self.lastFlush : lastFlush // ignore: cast_nullable_to_non_nullable
as FlushOutcome?,flushSerial: null == flushSerial ? _self.flushSerial : flushSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueStatsCopyWith<$Res>? get queue {
    if (_self.queue == null) {
    return null;
  }

  return $QueueStatsCopyWith<$Res>(_self.queue!, (value) {
    return _then(_self.copyWith(queue: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlushOutcomeCopyWith<$Res>? get lastFlush {
    if (_self.lastFlush == null) {
    return null;
  }

  return $FlushOutcomeCopyWith<$Res>(_self.lastFlush!, (value) {
    return _then(_self.copyWith(lastFlush: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QueueStats? queue,  bool flushing,  FlushOutcome? lastFlush,  int flushSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.queue,_that.flushing,_that.lastFlush,_that.flushSerial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QueueStats? queue,  bool flushing,  FlushOutcome? lastFlush,  int flushSerial)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.queue,_that.flushing,_that.lastFlush,_that.flushSerial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QueueStats? queue,  bool flushing,  FlushOutcome? lastFlush,  int flushSerial)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.queue,_that.flushing,_that.lastFlush,_that.flushSerial);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({this.queue, this.flushing = false, this.lastFlush, this.flushSerial = 0});
  

/// `null` until the first snapshot arrives.
@override final  QueueStats? queue;
/// A flush is running (the button waits for it).
@override@JsonKey() final  bool flushing;
/// The last flush's outcome, shown once; [flushSerial] makes a repeat
/// show again.
@override final  FlushOutcome? lastFlush;
@override@JsonKey() final  int flushSerial;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.queue, queue) || other.queue == queue)&&(identical(other.flushing, flushing) || other.flushing == flushing)&&(identical(other.lastFlush, lastFlush) || other.lastFlush == lastFlush)&&(identical(other.flushSerial, flushSerial) || other.flushSerial == flushSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,queue,flushing,lastFlush,flushSerial);
}

@override
String toString() {
    return 'DashboardState(queue: $queue, flushing: $flushing, lastFlush: $lastFlush, flushSerial: $flushSerial)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 QueueStats? queue, bool flushing, FlushOutcome? lastFlush, int flushSerial
});


@override $QueueStatsCopyWith<$Res>? get queue;@override $FlushOutcomeCopyWith<$Res>? get lastFlush;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = freezed,Object? flushing = null,Object? lastFlush = freezed,Object? flushSerial = null,}) {
  return _then(_DashboardState(
queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as QueueStats?,flushing: null == flushing ? _self.flushing : flushing // ignore: cast_nullable_to_non_nullable
as bool,lastFlush: freezed == lastFlush ? _self.lastFlush : lastFlush // ignore: cast_nullable_to_non_nullable
as FlushOutcome?,flushSerial: null == flushSerial ? _self.flushSerial : flushSerial // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueueStatsCopyWith<$Res>? get queue {
    if (_self.queue == null) {
    return null;
  }

  return $QueueStatsCopyWith<$Res>(_self.queue!, (value) {
    return _then(_self.copyWith(queue: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlushOutcomeCopyWith<$Res>? get lastFlush {
    if (_self.lastFlush == null) {
    return null;
  }

  return $FlushOutcomeCopyWith<$Res>(_self.lastFlush!, (value) {
    return _then(_self.copyWith(lastFlush: value));
  });
}
}

// dart format on
