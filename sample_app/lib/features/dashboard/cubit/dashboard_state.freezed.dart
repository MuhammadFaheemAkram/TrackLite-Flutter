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
mixin _$DashboardEffect {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardEffect);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DashboardEffect()';
}


}

/// @nodoc
class $DashboardEffectCopyWith<$Res>  {
$DashboardEffectCopyWith(DashboardEffect _, $Res Function(DashboardEffect) __);
}


/// Adds pattern-matching-related methods to [DashboardEffect].
extension DashboardEffectPatterns on DashboardEffect {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Flushed value)?  flushed,TResult Function( Retried value)?  retried,TResult Function( TrackedBurst value)?  tracked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Flushed() when flushed != null:
return flushed(_that);case Retried() when retried != null:
return retried(_that);case TrackedBurst() when tracked != null:
return tracked(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Flushed value)  flushed,required TResult Function( Retried value)  retried,required TResult Function( TrackedBurst value)  tracked,}){
final _that = this;
switch (_that) {
case Flushed():
return flushed(_that);case Retried():
return retried(_that);case TrackedBurst():
return tracked(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Flushed value)?  flushed,TResult? Function( Retried value)?  retried,TResult? Function( TrackedBurst value)?  tracked,}){
final _that = this;
switch (_that) {
case Flushed() when flushed != null:
return flushed(_that);case Retried() when retried != null:
return retried(_that);case TrackedBurst() when tracked != null:
return tracked(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( FlushOutcome outcome)?  flushed,TResult Function( int count)?  retried,TResult Function( int count)?  tracked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Flushed() when flushed != null:
return flushed(_that.outcome);case Retried() when retried != null:
return retried(_that.count);case TrackedBurst() when tracked != null:
return tracked(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( FlushOutcome outcome)  flushed,required TResult Function( int count)  retried,required TResult Function( int count)  tracked,}) {final _that = this;
switch (_that) {
case Flushed():
return flushed(_that.outcome);case Retried():
return retried(_that.count);case TrackedBurst():
return tracked(_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( FlushOutcome outcome)?  flushed,TResult? Function( int count)?  retried,TResult? Function( int count)?  tracked,}) {final _that = this;
switch (_that) {
case Flushed() when flushed != null:
return flushed(_that.outcome);case Retried() when retried != null:
return retried(_that.count);case TrackedBurst() when tracked != null:
return tracked(_that.count);case _:
  return null;

}
}

}

/// @nodoc


class Flushed implements DashboardEffect {
  const Flushed(this.outcome);
  

 final  FlushOutcome outcome;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlushedCopyWith<Flushed> get copyWith => _$FlushedCopyWithImpl<Flushed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Flushed&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode {
    return Object.hash(runtimeType,outcome);
}

@override
String toString() {
    return 'DashboardEffect.flushed(outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class $FlushedCopyWith<$Res> implements $DashboardEffectCopyWith<$Res> {
  factory $FlushedCopyWith(Flushed value, $Res Function(Flushed) _then) = _$FlushedCopyWithImpl;
@useResult
$Res call({
 FlushOutcome outcome
});


$FlushOutcomeCopyWith<$Res> get outcome;

}
/// @nodoc
class _$FlushedCopyWithImpl<$Res>
    implements $FlushedCopyWith<$Res> {
  _$FlushedCopyWithImpl(this._self, this._then);

  final Flushed _self;
  final $Res Function(Flushed) _then;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outcome = null,}) {
  return _then(Flushed(
null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as FlushOutcome,
  ));
}

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlushOutcomeCopyWith<$Res> get outcome {
  
  return $FlushOutcomeCopyWith<$Res>(_self.outcome, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

/// @nodoc


class Retried implements DashboardEffect {
  const Retried(this.count);
  

 final  int count;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetriedCopyWith<Retried> get copyWith => _$RetriedCopyWithImpl<Retried>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Retried&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count);
}

@override
String toString() {
    return 'DashboardEffect.retried(count: $count)';
}


}

/// @nodoc
abstract mixin class $RetriedCopyWith<$Res> implements $DashboardEffectCopyWith<$Res> {
  factory $RetriedCopyWith(Retried value, $Res Function(Retried) _then) = _$RetriedCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$RetriedCopyWithImpl<$Res>
    implements $RetriedCopyWith<$Res> {
  _$RetriedCopyWithImpl(this._self, this._then);

  final Retried _self;
  final $Res Function(Retried) _then;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(Retried(
null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TrackedBurst implements DashboardEffect {
  const TrackedBurst(this.count);
  

 final  int count;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackedBurstCopyWith<TrackedBurst> get copyWith => _$TrackedBurstCopyWithImpl<TrackedBurst>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackedBurst&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count);
}

@override
String toString() {
    return 'DashboardEffect.tracked(count: $count)';
}


}

/// @nodoc
abstract mixin class $TrackedBurstCopyWith<$Res> implements $DashboardEffectCopyWith<$Res> {
  factory $TrackedBurstCopyWith(TrackedBurst value, $Res Function(TrackedBurst) _then) = _$TrackedBurstCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$TrackedBurstCopyWithImpl<$Res>
    implements $TrackedBurstCopyWith<$Res> {
  _$TrackedBurstCopyWithImpl(this._self, this._then);

  final TrackedBurst _self;
  final $Res Function(TrackedBurst) _then;

/// Create a copy of DashboardEffect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(TrackedBurst(
null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DashboardState {

/// `null` until the first snapshot arrives.
 QueueStats? get queue;/// The device's network and the demo switch; `null` until known.
 NetworkStatus? get network;/// The demo server's settings and stats; `null` until known.
 DemoServerState? get server;/// The newest events, newest first.
 List<RecentEvent> get recentEvents;/// The newest upload runs, newest first.
 List<UploadRun> get uploads;/// A flush is running (the button waits for it).
 bool get flushing;/// The last thing to say, shown once; [effectSerial] makes a repeat
/// show again.
 DashboardEffect? get effect; int get effectSerial;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.queue, _this.queue) || other.queue == _this.queue)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.server, _this.server) || other.server == _this.server)&&const DeepCollectionEquality().equals(other.recentEvents, _this.recentEvents)&&const DeepCollectionEquality().equals(other.uploads, _this.uploads)&&(identical(other.flushing, _this.flushing) || other.flushing == _this.flushing)&&(identical(other.effect, _this.effect) || other.effect == _this.effect)&&(identical(other.effectSerial, _this.effectSerial) || other.effectSerial == _this.effectSerial));
}


@override
int get hashCode {
  final _this = this as DashboardState;
  return Object.hash(runtimeType,_this.queue,_this.network,_this.server,const DeepCollectionEquality().hash(_this.recentEvents),const DeepCollectionEquality().hash(_this.uploads),_this.flushing,_this.effect,_this.effectSerial);
}

@override
String toString() {
  final _this = this as DashboardState;
  return 'DashboardState(queue: ${_this.queue}, network: ${_this.network}, server: ${_this.server}, recentEvents: ${_this.recentEvents}, uploads: ${_this.uploads}, flushing: ${_this.flushing}, effect: ${_this.effect}, effectSerial: ${_this.effectSerial})';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 QueueStats? queue, NetworkStatus? network, DemoServerState? server, List<RecentEvent> recentEvents, List<UploadRun> uploads, bool flushing, DashboardEffect? effect, int effectSerial
});


$QueueStatsCopyWith<$Res>? get queue;$NetworkStatusCopyWith<$Res>? get network;$DemoServerStateCopyWith<$Res>? get server;$DashboardEffectCopyWith<$Res>? get effect;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = freezed,Object? network = freezed,Object? server = freezed,Object? recentEvents = null,Object? uploads = null,Object? flushing = null,Object? effect = freezed,Object? effectSerial = null,}) {
  return _then(DashboardState(
queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as QueueStats?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as NetworkStatus?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as DemoServerState?,recentEvents: null == recentEvents ? _self.recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<RecentEvent>,uploads: null == uploads ? _self.uploads : uploads // ignore: cast_nullable_to_non_nullable
as List<UploadRun>,flushing: null == flushing ? _self.flushing : flushing // ignore: cast_nullable_to_non_nullable
as bool,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as DashboardEffect?,effectSerial: null == effectSerial ? _self.effectSerial : effectSerial // ignore: cast_nullable_to_non_nullable
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
$NetworkStatusCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $NetworkStatusCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DemoServerStateCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $DemoServerStateCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardEffectCopyWith<$Res>? get effect {
    if (_self.effect == null) {
    return null;
  }

  return $DashboardEffectCopyWith<$Res>(_self.effect!, (value) {
    return _then(_self.copyWith(effect: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QueueStats? queue,  NetworkStatus? network,  DemoServerState? server,  List<RecentEvent> recentEvents,  List<UploadRun> uploads,  bool flushing,  DashboardEffect? effect,  int effectSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.queue,_that.network,_that.server,_that.recentEvents,_that.uploads,_that.flushing,_that.effect,_that.effectSerial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QueueStats? queue,  NetworkStatus? network,  DemoServerState? server,  List<RecentEvent> recentEvents,  List<UploadRun> uploads,  bool flushing,  DashboardEffect? effect,  int effectSerial)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.queue,_that.network,_that.server,_that.recentEvents,_that.uploads,_that.flushing,_that.effect,_that.effectSerial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QueueStats? queue,  NetworkStatus? network,  DemoServerState? server,  List<RecentEvent> recentEvents,  List<UploadRun> uploads,  bool flushing,  DashboardEffect? effect,  int effectSerial)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.queue,_that.network,_that.server,_that.recentEvents,_that.uploads,_that.flushing,_that.effect,_that.effectSerial);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({this.queue, this.network, this.server,  List<RecentEvent> recentEvents = const <RecentEvent>[],  List<UploadRun> uploads = const <UploadRun>[], this.flushing = false, this.effect, this.effectSerial = 0}): _recentEvents = recentEvents,_uploads = uploads;
  

/// `null` until the first snapshot arrives.
@override final  QueueStats? queue;
/// The device's network and the demo switch; `null` until known.
@override final  NetworkStatus? network;
/// The demo server's settings and stats; `null` until known.
@override final  DemoServerState? server;
/// The newest events, newest first.
 final  List<RecentEvent> _recentEvents;
/// The newest events, newest first.
@override@JsonKey() List<RecentEvent> get recentEvents {
  if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentEvents);
}

/// The newest upload runs, newest first.
 final  List<UploadRun> _uploads;
/// The newest upload runs, newest first.
@override@JsonKey() List<UploadRun> get uploads {
  if (_uploads is EqualUnmodifiableListView) return _uploads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploads);
}

/// A flush is running (the button waits for it).
@override@JsonKey() final  bool flushing;
/// The last thing to say, shown once; [effectSerial] makes a repeat
/// show again.
@override final  DashboardEffect? effect;
@override@JsonKey() final  int effectSerial;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.queue, queue) || other.queue == queue)&&(identical(other.network, network) || other.network == network)&&(identical(other.server, server) || other.server == server)&&const DeepCollectionEquality().equals(other.recentEvents, _recentEvents)&&const DeepCollectionEquality().equals(other.uploads, _uploads)&&(identical(other.flushing, flushing) || other.flushing == flushing)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.effectSerial, effectSerial) || other.effectSerial == effectSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,queue,network,server,const DeepCollectionEquality().hash(_recentEvents),const DeepCollectionEquality().hash(_uploads),flushing,effect,effectSerial);
}

@override
String toString() {
    return 'DashboardState(queue: $queue, network: $network, server: $server, recentEvents: $recentEvents, uploads: $uploads, flushing: $flushing, effect: $effect, effectSerial: $effectSerial)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 QueueStats? queue, NetworkStatus? network, DemoServerState? server, List<RecentEvent> recentEvents, List<UploadRun> uploads, bool flushing, DashboardEffect? effect, int effectSerial
});


@override $QueueStatsCopyWith<$Res>? get queue;@override $NetworkStatusCopyWith<$Res>? get network;@override $DemoServerStateCopyWith<$Res>? get server;@override $DashboardEffectCopyWith<$Res>? get effect;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = freezed,Object? network = freezed,Object? server = freezed,Object? recentEvents = null,Object? uploads = null,Object? flushing = null,Object? effect = freezed,Object? effectSerial = null,}) {
  return _then(_DashboardState(
queue: freezed == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as QueueStats?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as NetworkStatus?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as DemoServerState?,recentEvents: null == recentEvents ? _self._recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<RecentEvent>,uploads: null == uploads ? _self._uploads : uploads // ignore: cast_nullable_to_non_nullable
as List<UploadRun>,flushing: null == flushing ? _self.flushing : flushing // ignore: cast_nullable_to_non_nullable
as bool,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as DashboardEffect?,effectSerial: null == effectSerial ? _self.effectSerial : effectSerial // ignore: cast_nullable_to_non_nullable
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
$NetworkStatusCopyWith<$Res>? get network {
    if (_self.network == null) {
    return null;
  }

  return $NetworkStatusCopyWith<$Res>(_self.network!, (value) {
    return _then(_self.copyWith(network: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DemoServerStateCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $DemoServerStateCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardEffectCopyWith<$Res>? get effect {
    if (_self.effect == null) {
    return null;
  }

  return $DashboardEffectCopyWith<$Res>(_self.effect!, (value) {
    return _then(_self.copyWith(effect: value));
  });
}
}

// dart format on
