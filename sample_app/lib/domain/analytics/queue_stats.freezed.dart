// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueueStats {

 String get anonymousId; int get tracked; int get pending; int get sending; int get sent; int get failed; int get dropped; int get rejected; String? get userId;/// When the earliest retry is due, if an event waits for one.
 DateTime? get nextRetryAt;/// The newest upload run, if any.
 UploadRun? get lastUpload;/// Whether an upload is running now.
 bool get uploading;
/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueStatsCopyWith<QueueStats> get copyWith => _$QueueStatsCopyWithImpl<QueueStats>(this as QueueStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QueueStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueStats&&(identical(other.anonymousId, _this.anonymousId) || other.anonymousId == _this.anonymousId)&&(identical(other.tracked, _this.tracked) || other.tracked == _this.tracked)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.sending, _this.sending) || other.sending == _this.sending)&&(identical(other.sent, _this.sent) || other.sent == _this.sent)&&(identical(other.failed, _this.failed) || other.failed == _this.failed)&&(identical(other.dropped, _this.dropped) || other.dropped == _this.dropped)&&(identical(other.rejected, _this.rejected) || other.rejected == _this.rejected)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.nextRetryAt, _this.nextRetryAt) || other.nextRetryAt == _this.nextRetryAt)&&(identical(other.lastUpload, _this.lastUpload) || other.lastUpload == _this.lastUpload)&&(identical(other.uploading, _this.uploading) || other.uploading == _this.uploading));
}


@override
int get hashCode {
  final _this = this as QueueStats;
  return Object.hash(runtimeType,_this.anonymousId,_this.tracked,_this.pending,_this.sending,_this.sent,_this.failed,_this.dropped,_this.rejected,_this.userId,_this.nextRetryAt,_this.lastUpload,_this.uploading);
}

@override
String toString() {
  final _this = this as QueueStats;
  return 'QueueStats(anonymousId: ${_this.anonymousId}, tracked: ${_this.tracked}, pending: ${_this.pending}, sending: ${_this.sending}, sent: ${_this.sent}, failed: ${_this.failed}, dropped: ${_this.dropped}, rejected: ${_this.rejected}, userId: ${_this.userId}, nextRetryAt: ${_this.nextRetryAt}, lastUpload: ${_this.lastUpload}, uploading: ${_this.uploading})';
}


}

/// @nodoc
abstract mixin class $QueueStatsCopyWith<$Res>  {
  factory $QueueStatsCopyWith(QueueStats value, $Res Function(QueueStats) _then) = _$QueueStatsCopyWithImpl;
@useResult
$Res call({
 String anonymousId, int tracked, int pending, int sending, int sent, int failed, int dropped, int rejected, String? userId, DateTime? nextRetryAt, UploadRun? lastUpload, bool uploading
});


$UploadRunCopyWith<$Res>? get lastUpload;

}
/// @nodoc
class _$QueueStatsCopyWithImpl<$Res>
    implements $QueueStatsCopyWith<$Res> {
  _$QueueStatsCopyWithImpl(this._self, this._then);

  final QueueStats _self;
  final $Res Function(QueueStats) _then;

/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? anonymousId = null,Object? tracked = null,Object? pending = null,Object? sending = null,Object? sent = null,Object? failed = null,Object? dropped = null,Object? rejected = null,Object? userId = freezed,Object? nextRetryAt = freezed,Object? lastUpload = freezed,Object? uploading = null,}) {
  return _then(QueueStats(
anonymousId: null == anonymousId ? _self.anonymousId : anonymousId // ignore: cast_nullable_to_non_nullable
as String,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as int,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpload: freezed == lastUpload ? _self.lastUpload : lastUpload // ignore: cast_nullable_to_non_nullable
as UploadRun?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadRunCopyWith<$Res>? get lastUpload {
    if (_self.lastUpload == null) {
    return null;
  }

  return $UploadRunCopyWith<$Res>(_self.lastUpload!, (value) {
    return _then(_self.copyWith(lastUpload: value));
  });
}
}


/// Adds pattern-matching-related methods to [QueueStats].
extension QueueStatsPatterns on QueueStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueStats value)  $default,){
final _that = this;
switch (_that) {
case _QueueStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueStats value)?  $default,){
final _that = this;
switch (_that) {
case _QueueStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String anonymousId,  int tracked,  int pending,  int sending,  int sent,  int failed,  int dropped,  int rejected,  String? userId,  DateTime? nextRetryAt,  UploadRun? lastUpload,  bool uploading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueStats() when $default != null:
return $default(_that.anonymousId,_that.tracked,_that.pending,_that.sending,_that.sent,_that.failed,_that.dropped,_that.rejected,_that.userId,_that.nextRetryAt,_that.lastUpload,_that.uploading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String anonymousId,  int tracked,  int pending,  int sending,  int sent,  int failed,  int dropped,  int rejected,  String? userId,  DateTime? nextRetryAt,  UploadRun? lastUpload,  bool uploading)  $default,) {final _that = this;
switch (_that) {
case _QueueStats():
return $default(_that.anonymousId,_that.tracked,_that.pending,_that.sending,_that.sent,_that.failed,_that.dropped,_that.rejected,_that.userId,_that.nextRetryAt,_that.lastUpload,_that.uploading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String anonymousId,  int tracked,  int pending,  int sending,  int sent,  int failed,  int dropped,  int rejected,  String? userId,  DateTime? nextRetryAt,  UploadRun? lastUpload,  bool uploading)?  $default,) {final _that = this;
switch (_that) {
case _QueueStats() when $default != null:
return $default(_that.anonymousId,_that.tracked,_that.pending,_that.sending,_that.sent,_that.failed,_that.dropped,_that.rejected,_that.userId,_that.nextRetryAt,_that.lastUpload,_that.uploading);case _:
  return null;

}
}

}

/// @nodoc


class _QueueStats implements QueueStats {
  const _QueueStats({required this.anonymousId, this.tracked = 0, this.pending = 0, this.sending = 0, this.sent = 0, this.failed = 0, this.dropped = 0, this.rejected = 0, this.userId, this.nextRetryAt, this.lastUpload, this.uploading = false});
  

@override final  String anonymousId;
@override@JsonKey() final  int tracked;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int sending;
@override@JsonKey() final  int sent;
@override@JsonKey() final  int failed;
@override@JsonKey() final  int dropped;
@override@JsonKey() final  int rejected;
@override final  String? userId;
/// When the earliest retry is due, if an event waits for one.
@override final  DateTime? nextRetryAt;
/// The newest upload run, if any.
@override final  UploadRun? lastUpload;
/// Whether an upload is running now.
@override@JsonKey() final  bool uploading;

/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueStatsCopyWith<_QueueStats> get copyWith => __$QueueStatsCopyWithImpl<_QueueStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueStats&&(identical(other.anonymousId, anonymousId) || other.anonymousId == anonymousId)&&(identical(other.tracked, tracked) || other.tracked == tracked)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.dropped, dropped) || other.dropped == dropped)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nextRetryAt, nextRetryAt) || other.nextRetryAt == nextRetryAt)&&(identical(other.lastUpload, lastUpload) || other.lastUpload == lastUpload)&&(identical(other.uploading, uploading) || other.uploading == uploading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,anonymousId,tracked,pending,sending,sent,failed,dropped,rejected,userId,nextRetryAt,lastUpload,uploading);
}

@override
String toString() {
    return 'QueueStats(anonymousId: $anonymousId, tracked: $tracked, pending: $pending, sending: $sending, sent: $sent, failed: $failed, dropped: $dropped, rejected: $rejected, userId: $userId, nextRetryAt: $nextRetryAt, lastUpload: $lastUpload, uploading: $uploading)';
}


}

/// @nodoc
abstract mixin class _$QueueStatsCopyWith<$Res> implements $QueueStatsCopyWith<$Res> {
  factory _$QueueStatsCopyWith(_QueueStats value, $Res Function(_QueueStats) _then) = __$QueueStatsCopyWithImpl;
@override @useResult
$Res call({
 String anonymousId, int tracked, int pending, int sending, int sent, int failed, int dropped, int rejected, String? userId, DateTime? nextRetryAt, UploadRun? lastUpload, bool uploading
});


@override $UploadRunCopyWith<$Res>? get lastUpload;

}
/// @nodoc
class __$QueueStatsCopyWithImpl<$Res>
    implements _$QueueStatsCopyWith<$Res> {
  __$QueueStatsCopyWithImpl(this._self, this._then);

  final _QueueStats _self;
  final $Res Function(_QueueStats) _then;

/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? anonymousId = null,Object? tracked = null,Object? pending = null,Object? sending = null,Object? sent = null,Object? failed = null,Object? dropped = null,Object? rejected = null,Object? userId = freezed,Object? nextRetryAt = freezed,Object? lastUpload = freezed,Object? uploading = null,}) {
  return _then(_QueueStats(
anonymousId: null == anonymousId ? _self.anonymousId : anonymousId // ignore: cast_nullable_to_non_nullable
as String,tracked: null == tracked ? _self.tracked : tracked // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as int,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpload: freezed == lastUpload ? _self.lastUpload : lastUpload // ignore: cast_nullable_to_non_nullable
as UploadRun?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of QueueStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadRunCopyWith<$Res>? get lastUpload {
    if (_self.lastUpload == null) {
    return null;
  }

  return $UploadRunCopyWith<$Res>(_self.lastUpload!, (value) {
    return _then(_self.copyWith(lastUpload: value));
  });
}
}

// dart format on
