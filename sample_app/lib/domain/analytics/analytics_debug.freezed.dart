// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_debug.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentEvent {

 String get id; String get name; DateTime get trackedAt; EventState get state;/// The properties in short: `screen: product, price: 12.5`.
 String get summary; int get attempts; DateTime? get retryAt; String? get lastError;
/// Create a copy of RecentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentEventCopyWith<RecentEvent> get copyWith => _$RecentEventCopyWithImpl<RecentEvent>(this as RecentEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecentEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.trackedAt, _this.trackedAt) || other.trackedAt == _this.trackedAt)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.retryAt, _this.retryAt) || other.retryAt == _this.retryAt)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError));
}


@override
int get hashCode {
  final _this = this as RecentEvent;
  return Object.hash(runtimeType,_this.id,_this.name,_this.trackedAt,_this.state,_this.summary,_this.attempts,_this.retryAt,_this.lastError);
}

@override
String toString() {
  final _this = this as RecentEvent;
  return 'RecentEvent(id: ${_this.id}, name: ${_this.name}, trackedAt: ${_this.trackedAt}, state: ${_this.state}, summary: ${_this.summary}, attempts: ${_this.attempts}, retryAt: ${_this.retryAt}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $RecentEventCopyWith<$Res>  {
  factory $RecentEventCopyWith(RecentEvent value, $Res Function(RecentEvent) _then) = _$RecentEventCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime trackedAt, EventState state, String summary, int attempts, DateTime? retryAt, String? lastError
});




}
/// @nodoc
class _$RecentEventCopyWithImpl<$Res>
    implements $RecentEventCopyWith<$Res> {
  _$RecentEventCopyWithImpl(this._self, this._then);

  final RecentEvent _self;
  final $Res Function(RecentEvent) _then;

/// Create a copy of RecentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? trackedAt = null,Object? state = null,Object? summary = null,Object? attempts = null,Object? retryAt = freezed,Object? lastError = freezed,}) {
  return _then(RecentEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trackedAt: null == trackedAt ? _self.trackedAt : trackedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EventState,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentEvent].
extension RecentEventPatterns on RecentEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentEvent value)  $default,){
final _that = this;
switch (_that) {
case _RecentEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentEvent value)?  $default,){
final _that = this;
switch (_that) {
case _RecentEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime trackedAt,  EventState state,  String summary,  int attempts,  DateTime? retryAt,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentEvent() when $default != null:
return $default(_that.id,_that.name,_that.trackedAt,_that.state,_that.summary,_that.attempts,_that.retryAt,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime trackedAt,  EventState state,  String summary,  int attempts,  DateTime? retryAt,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _RecentEvent():
return $default(_that.id,_that.name,_that.trackedAt,_that.state,_that.summary,_that.attempts,_that.retryAt,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime trackedAt,  EventState state,  String summary,  int attempts,  DateTime? retryAt,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _RecentEvent() when $default != null:
return $default(_that.id,_that.name,_that.trackedAt,_that.state,_that.summary,_that.attempts,_that.retryAt,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _RecentEvent implements RecentEvent {
  const _RecentEvent({required this.id, required this.name, required this.trackedAt, required this.state, this.summary = '', this.attempts = 0, this.retryAt, this.lastError});
  

@override final  String id;
@override final  String name;
@override final  DateTime trackedAt;
@override final  EventState state;
/// The properties in short: `screen: product, price: 12.5`.
@override@JsonKey() final  String summary;
@override@JsonKey() final  int attempts;
@override final  DateTime? retryAt;
@override final  String? lastError;

/// Create a copy of RecentEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentEventCopyWith<_RecentEvent> get copyWith => __$RecentEventCopyWithImpl<_RecentEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.trackedAt, trackedAt) || other.trackedAt == trackedAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,trackedAt,state,summary,attempts,retryAt,lastError);
}

@override
String toString() {
    return 'RecentEvent(id: $id, name: $name, trackedAt: $trackedAt, state: $state, summary: $summary, attempts: $attempts, retryAt: $retryAt, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$RecentEventCopyWith<$Res> implements $RecentEventCopyWith<$Res> {
  factory _$RecentEventCopyWith(_RecentEvent value, $Res Function(_RecentEvent) _then) = __$RecentEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime trackedAt, EventState state, String summary, int attempts, DateTime? retryAt, String? lastError
});




}
/// @nodoc
class __$RecentEventCopyWithImpl<$Res>
    implements _$RecentEventCopyWith<$Res> {
  __$RecentEventCopyWithImpl(this._self, this._then);

  final _RecentEvent _self;
  final $Res Function(_RecentEvent) _then;

/// Create a copy of RecentEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? trackedAt = null,Object? state = null,Object? summary = null,Object? attempts = null,Object? retryAt = freezed,Object? lastError = freezed,}) {
  return _then(_RecentEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trackedAt: null == trackedAt ? _self.trackedAt : trackedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EventState,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$UploadRun {

/// What started it, as the SDK names it (`manual`, `interval`, …).
 String get trigger; DateTime get finishedAt; UploadOutcome get outcome; int get events; String? get error;
/// Create a copy of UploadRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadRunCopyWith<UploadRun> get copyWith => _$UploadRunCopyWithImpl<UploadRun>(this as UploadRun, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UploadRun;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadRun&&(identical(other.trigger, _this.trigger) || other.trigger == _this.trigger)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.events, _this.events) || other.events == _this.events)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as UploadRun;
  return Object.hash(runtimeType,_this.trigger,_this.finishedAt,_this.outcome,_this.events,_this.error);
}

@override
String toString() {
  final _this = this as UploadRun;
  return 'UploadRun(trigger: ${_this.trigger}, finishedAt: ${_this.finishedAt}, outcome: ${_this.outcome}, events: ${_this.events}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $UploadRunCopyWith<$Res>  {
  factory $UploadRunCopyWith(UploadRun value, $Res Function(UploadRun) _then) = _$UploadRunCopyWithImpl;
@useResult
$Res call({
 String trigger, DateTime finishedAt, UploadOutcome outcome, int events, String? error
});




}
/// @nodoc
class _$UploadRunCopyWithImpl<$Res>
    implements $UploadRunCopyWith<$Res> {
  _$UploadRunCopyWithImpl(this._self, this._then);

  final UploadRun _self;
  final $Res Function(UploadRun) _then;

/// Create a copy of UploadRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trigger = null,Object? finishedAt = null,Object? outcome = null,Object? events = null,Object? error = freezed,}) {
  return _then(UploadRun(
trigger: null == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as UploadOutcome,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadRun].
extension UploadRunPatterns on UploadRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadRun value)  $default,){
final _that = this;
switch (_that) {
case _UploadRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadRun value)?  $default,){
final _that = this;
switch (_that) {
case _UploadRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trigger,  DateTime finishedAt,  UploadOutcome outcome,  int events,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadRun() when $default != null:
return $default(_that.trigger,_that.finishedAt,_that.outcome,_that.events,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trigger,  DateTime finishedAt,  UploadOutcome outcome,  int events,  String? error)  $default,) {final _that = this;
switch (_that) {
case _UploadRun():
return $default(_that.trigger,_that.finishedAt,_that.outcome,_that.events,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trigger,  DateTime finishedAt,  UploadOutcome outcome,  int events,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _UploadRun() when $default != null:
return $default(_that.trigger,_that.finishedAt,_that.outcome,_that.events,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _UploadRun implements UploadRun {
  const _UploadRun({required this.trigger, required this.finishedAt, required this.outcome, this.events = 0, this.error});
  

/// What started it, as the SDK names it (`manual`, `interval`, …).
@override final  String trigger;
@override final  DateTime finishedAt;
@override final  UploadOutcome outcome;
@override@JsonKey() final  int events;
@override final  String? error;

/// Create a copy of UploadRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadRunCopyWith<_UploadRun> get copyWith => __$UploadRunCopyWithImpl<_UploadRun>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadRun&&(identical(other.trigger, trigger) || other.trigger == trigger)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.events, events) || other.events == events)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trigger,finishedAt,outcome,events,error);
}

@override
String toString() {
    return 'UploadRun(trigger: $trigger, finishedAt: $finishedAt, outcome: $outcome, events: $events, error: $error)';
}


}

/// @nodoc
abstract mixin class _$UploadRunCopyWith<$Res> implements $UploadRunCopyWith<$Res> {
  factory _$UploadRunCopyWith(_UploadRun value, $Res Function(_UploadRun) _then) = __$UploadRunCopyWithImpl;
@override @useResult
$Res call({
 String trigger, DateTime finishedAt, UploadOutcome outcome, int events, String? error
});




}
/// @nodoc
class __$UploadRunCopyWithImpl<$Res>
    implements _$UploadRunCopyWith<$Res> {
  __$UploadRunCopyWithImpl(this._self, this._then);

  final _UploadRun _self;
  final $Res Function(_UploadRun) _then;

/// Create a copy of UploadRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trigger = null,Object? finishedAt = null,Object? outcome = null,Object? events = null,Object? error = freezed,}) {
  return _then(_UploadRun(
trigger: null == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as UploadOutcome,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
