// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flush_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlushOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlushOutcome()';
}


}

/// @nodoc
class $FlushOutcomeCopyWith<$Res>  {
$FlushOutcomeCopyWith(FlushOutcome _, $Res Function(FlushOutcome) __);
}


/// Adds pattern-matching-related methods to [FlushOutcome].
extension FlushOutcomePatterns on FlushOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FlushSent value)?  sent,TResult Function( FlushNothingToSend value)?  nothingToSend,TResult Function( FlushOffline value)?  offline,TResult Function( FlushFailed value)?  failed,TResult Function( FlushKeyRejected value)?  keyRejected,TResult Function( FlushNotRunning value)?  notRunning,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FlushSent() when sent != null:
return sent(_that);case FlushNothingToSend() when nothingToSend != null:
return nothingToSend(_that);case FlushOffline() when offline != null:
return offline(_that);case FlushFailed() when failed != null:
return failed(_that);case FlushKeyRejected() when keyRejected != null:
return keyRejected(_that);case FlushNotRunning() when notRunning != null:
return notRunning(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FlushSent value)  sent,required TResult Function( FlushNothingToSend value)  nothingToSend,required TResult Function( FlushOffline value)  offline,required TResult Function( FlushFailed value)  failed,required TResult Function( FlushKeyRejected value)  keyRejected,required TResult Function( FlushNotRunning value)  notRunning,}){
final _that = this;
switch (_that) {
case FlushSent():
return sent(_that);case FlushNothingToSend():
return nothingToSend(_that);case FlushOffline():
return offline(_that);case FlushFailed():
return failed(_that);case FlushKeyRejected():
return keyRejected(_that);case FlushNotRunning():
return notRunning(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FlushSent value)?  sent,TResult? Function( FlushNothingToSend value)?  nothingToSend,TResult? Function( FlushOffline value)?  offline,TResult? Function( FlushFailed value)?  failed,TResult? Function( FlushKeyRejected value)?  keyRejected,TResult? Function( FlushNotRunning value)?  notRunning,}){
final _that = this;
switch (_that) {
case FlushSent() when sent != null:
return sent(_that);case FlushNothingToSend() when nothingToSend != null:
return nothingToSend(_that);case FlushOffline() when offline != null:
return offline(_that);case FlushFailed() when failed != null:
return failed(_that);case FlushKeyRejected() when keyRejected != null:
return keyRejected(_that);case FlushNotRunning() when notRunning != null:
return notRunning(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int events,  int requests)?  sent,TResult Function()?  nothingToSend,TResult Function()?  offline,TResult Function( String reason,  int waiting)?  failed,TResult Function()?  keyRejected,TResult Function()?  notRunning,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FlushSent() when sent != null:
return sent(_that.events,_that.requests);case FlushNothingToSend() when nothingToSend != null:
return nothingToSend();case FlushOffline() when offline != null:
return offline();case FlushFailed() when failed != null:
return failed(_that.reason,_that.waiting);case FlushKeyRejected() when keyRejected != null:
return keyRejected();case FlushNotRunning() when notRunning != null:
return notRunning();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int events,  int requests)  sent,required TResult Function()  nothingToSend,required TResult Function()  offline,required TResult Function( String reason,  int waiting)  failed,required TResult Function()  keyRejected,required TResult Function()  notRunning,}) {final _that = this;
switch (_that) {
case FlushSent():
return sent(_that.events,_that.requests);case FlushNothingToSend():
return nothingToSend();case FlushOffline():
return offline();case FlushFailed():
return failed(_that.reason,_that.waiting);case FlushKeyRejected():
return keyRejected();case FlushNotRunning():
return notRunning();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int events,  int requests)?  sent,TResult? Function()?  nothingToSend,TResult? Function()?  offline,TResult? Function( String reason,  int waiting)?  failed,TResult? Function()?  keyRejected,TResult? Function()?  notRunning,}) {final _that = this;
switch (_that) {
case FlushSent() when sent != null:
return sent(_that.events,_that.requests);case FlushNothingToSend() when nothingToSend != null:
return nothingToSend();case FlushOffline() when offline != null:
return offline();case FlushFailed() when failed != null:
return failed(_that.reason,_that.waiting);case FlushKeyRejected() when keyRejected != null:
return keyRejected();case FlushNotRunning() when notRunning != null:
return notRunning();case _:
  return null;

}
}

}

/// @nodoc


class FlushSent implements FlushOutcome {
  const FlushSent({required this.events, required this.requests});
  

 final  int events;
 final  int requests;

/// Create a copy of FlushOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlushSentCopyWith<FlushSent> get copyWith => _$FlushSentCopyWithImpl<FlushSent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushSent&&(identical(other.events, events) || other.events == events)&&(identical(other.requests, requests) || other.requests == requests));
}


@override
int get hashCode {
    return Object.hash(runtimeType,events,requests);
}

@override
String toString() {
    return 'FlushOutcome.sent(events: $events, requests: $requests)';
}


}

/// @nodoc
abstract mixin class $FlushSentCopyWith<$Res> implements $FlushOutcomeCopyWith<$Res> {
  factory $FlushSentCopyWith(FlushSent value, $Res Function(FlushSent) _then) = _$FlushSentCopyWithImpl;
@useResult
$Res call({
 int events, int requests
});




}
/// @nodoc
class _$FlushSentCopyWithImpl<$Res>
    implements $FlushSentCopyWith<$Res> {
  _$FlushSentCopyWithImpl(this._self, this._then);

  final FlushSent _self;
  final $Res Function(FlushSent) _then;

/// Create a copy of FlushOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? events = null,Object? requests = null,}) {
  return _then(FlushSent(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FlushNothingToSend implements FlushOutcome {
  const FlushNothingToSend();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushNothingToSend);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlushOutcome.nothingToSend()';
}


}




/// @nodoc


class FlushOffline implements FlushOutcome {
  const FlushOffline();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushOffline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlushOutcome.offline()';
}


}




/// @nodoc


class FlushFailed implements FlushOutcome {
  const FlushFailed({required this.reason, required this.waiting});
  

 final  String reason;
 final  int waiting;

/// Create a copy of FlushOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlushFailedCopyWith<FlushFailed> get copyWith => _$FlushFailedCopyWithImpl<FlushFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushFailed&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.waiting, waiting) || other.waiting == waiting));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason,waiting);
}

@override
String toString() {
    return 'FlushOutcome.failed(reason: $reason, waiting: $waiting)';
}


}

/// @nodoc
abstract mixin class $FlushFailedCopyWith<$Res> implements $FlushOutcomeCopyWith<$Res> {
  factory $FlushFailedCopyWith(FlushFailed value, $Res Function(FlushFailed) _then) = _$FlushFailedCopyWithImpl;
@useResult
$Res call({
 String reason, int waiting
});




}
/// @nodoc
class _$FlushFailedCopyWithImpl<$Res>
    implements $FlushFailedCopyWith<$Res> {
  _$FlushFailedCopyWithImpl(this._self, this._then);

  final FlushFailed _self;
  final $Res Function(FlushFailed) _then;

/// Create a copy of FlushOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? waiting = null,}) {
  return _then(FlushFailed(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,waiting: null == waiting ? _self.waiting : waiting // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FlushKeyRejected implements FlushOutcome {
  const FlushKeyRejected();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushKeyRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlushOutcome.keyRejected()';
}


}




/// @nodoc


class FlushNotRunning implements FlushOutcome {
  const FlushNotRunning();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FlushNotRunning);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FlushOutcome.notRunning()';
}


}




// dart format on
