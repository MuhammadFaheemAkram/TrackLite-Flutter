// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'tracklite_database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anonymousIdMeta = const VerificationMeta(
    'anonymousId',
  );
  @override
  late final GeneratedColumn<String> anonymousId = GeneratedColumn<String>(
    'anonymous_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propertiesMeta = const VerificationMeta(
    'properties',
  );
  @override
  late final GeneratedColumn<String> properties = GeneratedColumn<String>(
    'properties',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _claimTokenMeta = const VerificationMeta(
    'claimToken',
  );
  @override
  late final GeneratedColumn<String> claimToken = GeneratedColumn<String>(
    'claim_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  @override
  late final GeneratedColumn<DateTime> claimedAt = GeneratedColumn<DateTime>(
    'claimed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    id,
    name,
    timestamp,
    userId,
    anonymousId,
    properties,
    status,
    attempts,
    nextAttemptAt,
    claimToken,
    claimedAt,
    sentAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('anonymous_id')) {
      context.handle(
        _anonymousIdMeta,
        anonymousId.isAcceptableOrUnknown(
          data['anonymous_id']!,
          _anonymousIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anonymousIdMeta);
    }
    if (data.containsKey('properties')) {
      context.handle(
        _propertiesMeta,
        properties.isAcceptableOrUnknown(data['properties']!, _propertiesMeta),
      );
    } else if (isInserting) {
      context.missing(_propertiesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('claim_token')) {
      context.handle(
        _claimTokenMeta,
        claimToken.isAcceptableOrUnknown(data['claim_token']!, _claimTokenMeta),
      );
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      anonymousId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anonymous_id'],
      )!,
      properties: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}properties'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      claimToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_token'],
      ),
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}claimed_at'],
      ),
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  /// The insertion order: uploads go oldest first by this, and so does
  /// dropping when the queue is full.
  final int seq;

  /// The event's UUID: the server drops a second copy of the same id.
  final String id;
  final String name;

  /// When it was tracked (the host's clock, in UTC).
  final DateTime timestamp;
  final String? userId;
  final String anonymousId;

  /// A JSON object of `String`, number and `bool` values.
  final String properties;

  /// `pending`, `sending`, `sent` or `failed`.
  final String status;

  /// Server failures so far (failing to reach it doesn't count).
  final int attempts;

  /// When an automatic upload may try it again.
  final DateTime? nextAttemptAt;

  /// Which upload claimed it, and when: set exactly while `sending`.
  final String? claimToken;
  final DateTime? claimedAt;

  /// When the server accepted it: set exactly when `sent`.
  final DateTime? sentAt;
  final String? lastError;
  const EventRow({
    required this.seq,
    required this.id,
    required this.name,
    required this.timestamp,
    this.userId,
    required this.anonymousId,
    required this.properties,
    required this.status,
    required this.attempts,
    this.nextAttemptAt,
    this.claimToken,
    this.claimedAt,
    this.sentAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['anonymous_id'] = Variable<String>(anonymousId);
    map['properties'] = Variable<String>(properties);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || claimToken != null) {
      map['claim_token'] = Variable<String>(claimToken);
    }
    if (!nullToAbsent || claimedAt != null) {
      map['claimed_at'] = Variable<DateTime>(claimedAt);
    }
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      seq: Value(seq),
      id: Value(id),
      name: Value(name),
      timestamp: Value(timestamp),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      anonymousId: Value(anonymousId),
      properties: Value(properties),
      status: Value(status),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      claimToken: claimToken == null && nullToAbsent
          ? const Value.absent()
          : Value(claimToken),
      claimedAt: claimedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(claimedAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      seq: serializer.fromJson<int>(json['seq']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      userId: serializer.fromJson<String?>(json['userId']),
      anonymousId: serializer.fromJson<String>(json['anonymousId']),
      properties: serializer.fromJson<String>(json['properties']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      claimToken: serializer.fromJson<String?>(json['claimToken']),
      claimedAt: serializer.fromJson<DateTime?>(json['claimedAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'userId': serializer.toJson<String?>(userId),
      'anonymousId': serializer.toJson<String>(anonymousId),
      'properties': serializer.toJson<String>(properties),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'claimToken': serializer.toJson<String?>(claimToken),
      'claimedAt': serializer.toJson<DateTime?>(claimedAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  EventRow copyWith({
    int? seq,
    String? id,
    String? name,
    DateTime? timestamp,
    Value<String?> userId = const Value.absent(),
    String? anonymousId,
    String? properties,
    String? status,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> claimToken = const Value.absent(),
    Value<DateTime?> claimedAt = const Value.absent(),
    Value<DateTime?> sentAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => EventRow(
    seq: seq ?? this.seq,
    id: id ?? this.id,
    name: name ?? this.name,
    timestamp: timestamp ?? this.timestamp,
    userId: userId.present ? userId.value : this.userId,
    anonymousId: anonymousId ?? this.anonymousId,
    properties: properties ?? this.properties,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    claimToken: claimToken.present ? claimToken.value : this.claimToken,
    claimedAt: claimedAt.present ? claimedAt.value : this.claimedAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      userId: data.userId.present ? data.userId.value : this.userId,
      anonymousId: data.anonymousId.present
          ? data.anonymousId.value
          : this.anonymousId,
      properties: data.properties.present
          ? data.properties.value
          : this.properties,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      claimToken: data.claimToken.present
          ? data.claimToken.value
          : this.claimToken,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('anonymousId: $anonymousId, ')
          ..write('properties: $properties, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('claimToken: $claimToken, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    id,
    name,
    timestamp,
    userId,
    anonymousId,
    properties,
    status,
    attempts,
    nextAttemptAt,
    claimToken,
    claimedAt,
    sentAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.seq == this.seq &&
          other.id == this.id &&
          other.name == this.name &&
          other.timestamp == this.timestamp &&
          other.userId == this.userId &&
          other.anonymousId == this.anonymousId &&
          other.properties == this.properties &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.claimToken == this.claimToken &&
          other.claimedAt == this.claimedAt &&
          other.sentAt == this.sentAt &&
          other.lastError == this.lastError);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<int> seq;
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> timestamp;
  final Value<String?> userId;
  final Value<String> anonymousId;
  final Value<String> properties;
  final Value<String> status;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> claimToken;
  final Value<DateTime?> claimedAt;
  final Value<DateTime?> sentAt;
  final Value<String?> lastError;
  const EventsCompanion({
    this.seq = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.userId = const Value.absent(),
    this.anonymousId = const Value.absent(),
    this.properties = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  EventsCompanion.insert({
    this.seq = const Value.absent(),
    required String id,
    required String name,
    required DateTime timestamp,
    this.userId = const Value.absent(),
    required String anonymousId,
    required String properties,
    required String status,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       timestamp = Value(timestamp),
       anonymousId = Value(anonymousId),
       properties = Value(properties),
       status = Value(status);
  static Insertable<EventRow> custom({
    Expression<int>? seq,
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? timestamp,
    Expression<String>? userId,
    Expression<String>? anonymousId,
    Expression<String>? properties,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? claimToken,
    Expression<DateTime>? claimedAt,
    Expression<DateTime>? sentAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timestamp != null) 'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
      if (anonymousId != null) 'anonymous_id': anonymousId,
      if (properties != null) 'properties': properties,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (claimToken != null) 'claim_token': claimToken,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  EventsCompanion copyWith({
    Value<int>? seq,
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? timestamp,
    Value<String?>? userId,
    Value<String>? anonymousId,
    Value<String>? properties,
    Value<String>? status,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? claimToken,
    Value<DateTime?>? claimedAt,
    Value<DateTime?>? sentAt,
    Value<String?>? lastError,
  }) {
    return EventsCompanion(
      seq: seq ?? this.seq,
      id: id ?? this.id,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      anonymousId: anonymousId ?? this.anonymousId,
      properties: properties ?? this.properties,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      claimToken: claimToken ?? this.claimToken,
      claimedAt: claimedAt ?? this.claimedAt,
      sentAt: sentAt ?? this.sentAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (anonymousId.present) {
      map['anonymous_id'] = Variable<String>(anonymousId.value);
    }
    if (properties.present) {
      map['properties'] = Variable<String>(properties.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (claimToken.present) {
      map['claim_token'] = Variable<String>(claimToken.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<DateTime>(claimedAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('anonymousId: $anonymousId, ')
          ..write('properties: $properties, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('claimToken: $claimToken, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $MetaEntriesTable extends MetaEntries
    with TableInfo<$MetaEntriesTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaEntriesTable createAlias(String alias) {
    return $MetaEntriesTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String name;
  final String value;
  const MetaRow({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MetaEntriesCompanion(name: Value(name), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? name, String? value}) =>
      MetaRow(name: name ?? this.name, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaEntriesCompanion data) {
    return MetaRow(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow &&
          other.name == this.name &&
          other.value == this.value);
}

class MetaEntriesCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const MetaEntriesCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaEntriesCompanion.insert({
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaEntriesCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaEntriesCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntriesCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UploadsTable extends Uploads with TableInfo<$UploadsTable, UploadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchesMeta = const VerificationMeta(
    'batches',
  );
  @override
  late final GeneratedColumn<int> batches = GeneratedColumn<int>(
    'batches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _eventsMeta = const VerificationMeta('events');
  @override
  late final GeneratedColumn<int> events = GeneratedColumn<int>(
    'events',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trigger,
    startedAt,
    finishedAt,
    outcome,
    batches,
    events,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<UploadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('batches')) {
      context.handle(
        _batchesMeta,
        batches.isAcceptableOrUnknown(data['batches']!, _batchesMeta),
      );
    }
    if (data.containsKey('events')) {
      context.handle(
        _eventsMeta,
        events.isAcceptableOrUnknown(data['events']!, _eventsMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UploadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UploadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      batches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batches'],
      )!,
      events: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}events'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $UploadsTable createAlias(String alias) {
    return $UploadsTable(attachedDatabase, alias);
  }
}

class UploadRow extends DataClass implements Insertable<UploadRow> {
  final int id;

  /// What started it: `manual`, `interval`, `threshold`, …
  final String trigger;
  final DateTime startedAt;
  final DateTime finishedAt;

  /// `uploaded`, `nothing`, `offline`, `failed` or `unauthorized`.
  final String outcome;
  final int batches;
  final int events;
  final String? error;
  const UploadRow({
    required this.id,
    required this.trigger,
    required this.startedAt,
    required this.finishedAt,
    required this.outcome,
    required this.batches,
    required this.events,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trigger'] = Variable<String>(trigger);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['finished_at'] = Variable<DateTime>(finishedAt);
    map['outcome'] = Variable<String>(outcome);
    map['batches'] = Variable<int>(batches);
    map['events'] = Variable<int>(events);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  UploadsCompanion toCompanion(bool nullToAbsent) {
    return UploadsCompanion(
      id: Value(id),
      trigger: Value(trigger),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      outcome: Value(outcome),
      batches: Value(batches),
      events: Value(events),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory UploadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UploadRow(
      id: serializer.fromJson<int>(json['id']),
      trigger: serializer.fromJson<String>(json['trigger']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      outcome: serializer.fromJson<String>(json['outcome']),
      batches: serializer.fromJson<int>(json['batches']),
      events: serializer.fromJson<int>(json['events']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trigger': serializer.toJson<String>(trigger),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'outcome': serializer.toJson<String>(outcome),
      'batches': serializer.toJson<int>(batches),
      'events': serializer.toJson<int>(events),
      'error': serializer.toJson<String?>(error),
    };
  }

  UploadRow copyWith({
    int? id,
    String? trigger,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? outcome,
    int? batches,
    int? events,
    Value<String?> error = const Value.absent(),
  }) => UploadRow(
    id: id ?? this.id,
    trigger: trigger ?? this.trigger,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    outcome: outcome ?? this.outcome,
    batches: batches ?? this.batches,
    events: events ?? this.events,
    error: error.present ? error.value : this.error,
  );
  UploadRow copyWithCompanion(UploadsCompanion data) {
    return UploadRow(
      id: data.id.present ? data.id.value : this.id,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      batches: data.batches.present ? data.batches.value : this.batches,
      events: data.events.present ? data.events.value : this.events,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UploadRow(')
          ..write('id: $id, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('outcome: $outcome, ')
          ..write('batches: $batches, ')
          ..write('events: $events, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trigger,
    startedAt,
    finishedAt,
    outcome,
    batches,
    events,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UploadRow &&
          other.id == this.id &&
          other.trigger == this.trigger &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.outcome == this.outcome &&
          other.batches == this.batches &&
          other.events == this.events &&
          other.error == this.error);
}

class UploadsCompanion extends UpdateCompanion<UploadRow> {
  final Value<int> id;
  final Value<String> trigger;
  final Value<DateTime> startedAt;
  final Value<DateTime> finishedAt;
  final Value<String> outcome;
  final Value<int> batches;
  final Value<int> events;
  final Value<String?> error;
  const UploadsCompanion({
    this.id = const Value.absent(),
    this.trigger = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.batches = const Value.absent(),
    this.events = const Value.absent(),
    this.error = const Value.absent(),
  });
  UploadsCompanion.insert({
    this.id = const Value.absent(),
    required String trigger,
    required DateTime startedAt,
    required DateTime finishedAt,
    required String outcome,
    this.batches = const Value.absent(),
    this.events = const Value.absent(),
    this.error = const Value.absent(),
  }) : trigger = Value(trigger),
       startedAt = Value(startedAt),
       finishedAt = Value(finishedAt),
       outcome = Value(outcome);
  static Insertable<UploadRow> custom({
    Expression<int>? id,
    Expression<String>? trigger,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? outcome,
    Expression<int>? batches,
    Expression<int>? events,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trigger != null) 'trigger': trigger,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (outcome != null) 'outcome': outcome,
      if (batches != null) 'batches': batches,
      if (events != null) 'events': events,
      if (error != null) 'error': error,
    });
  }

  UploadsCompanion copyWith({
    Value<int>? id,
    Value<String>? trigger,
    Value<DateTime>? startedAt,
    Value<DateTime>? finishedAt,
    Value<String>? outcome,
    Value<int>? batches,
    Value<int>? events,
    Value<String?>? error,
  }) {
    return UploadsCompanion(
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      outcome: outcome ?? this.outcome,
      batches: batches ?? this.batches,
      events: events ?? this.events,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (batches.present) {
      map['batches'] = Variable<int>(batches.value);
    }
    if (events.present) {
      map['events'] = Variable<int>(events.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UploadsCompanion(')
          ..write('id: $id, ')
          ..write('trigger: $trigger, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('outcome: $outcome, ')
          ..write('batches: $batches, ')
          ..write('events: $events, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

abstract class _$TrackLiteDatabase extends GeneratedDatabase {
  _$TrackLiteDatabase(QueryExecutor e) : super(e);
  $TrackLiteDatabaseManager get managers => $TrackLiteDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MetaEntriesTable metaEntries = $MetaEntriesTable(this);
  late final $UploadsTable uploads = $UploadsTable(this);
  late final Index eventsByStatus = Index(
    'events_by_status',
    'CREATE INDEX events_by_status ON events (status, seq)',
  );
  late final EventDao eventDao = EventDao(this as TrackLiteDatabase);
  late final MetaDao metaDao = MetaDao(this as TrackLiteDatabase);
  late final UploadDao uploadDao = UploadDao(this as TrackLiteDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    events,
    metaEntries,
    uploads,
    eventsByStatus,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> seq,
  required String id,
  required String name,
  required DateTime timestamp,
  Value<String?> userId,
  required String anonymousId,
  required String properties,
  required String status,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> claimToken,
  Value<DateTime?> claimedAt,
  Value<DateTime?> sentAt,
  Value<String?> lastError,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> seq,
  Value<String> id,
  Value<String> name,
  Value<DateTime> timestamp,
  Value<String?> userId,
  Value<String> anonymousId,
  Value<String> properties,
  Value<String> status,
  Value<int> attempts,
  Value<DateTime?> nextAttemptAt,
  Value<String?> claimToken,
  Value<DateTime?> claimedAt,
  Value<DateTime?> sentAt,
  Value<String?> lastError,
});

class $$EventsTableFilterComposer
    extends Composer<_$TrackLiteDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anonymousId => $composableBuilder(
    column: $table.anonymousId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$TrackLiteDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anonymousId => $composableBuilder(
    column: $table.anonymousId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$TrackLiteDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get anonymousId => $composableBuilder(
    column: $table.anonymousId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get properties => $composableBuilder(
    column: $table.properties,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$TrackLiteDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (
            EventRow,
            BaseReferences<_$TrackLiteDatabase, $EventsTable, EventRow>,
          ),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$TrackLiteDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> anonymousId = const Value.absent(),
                Value<String> properties = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> claimToken = const Value.absent(),
                Value<DateTime?> claimedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => EventsCompanion(
                seq: seq,
                id: id,
                name: name,
                timestamp: timestamp,
                userId: userId,
                anonymousId: anonymousId,
                properties: properties,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                claimToken: claimToken,
                claimedAt: claimedAt,
                sentAt: sentAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String id,
                required String name,
                required DateTime timestamp,
                Value<String?> userId = const Value.absent(),
                required String anonymousId,
                required String properties,
                required String status,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> claimToken = const Value.absent(),
                Value<DateTime?> claimedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => EventsCompanion.insert(
                seq: seq,
                id: id,
                name: name,
                timestamp: timestamp,
                userId: userId,
                anonymousId: anonymousId,
                properties: properties,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                claimToken: claimToken,
                claimedAt: claimedAt,
                sentAt: sentAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, EventRow>(table),
                  BaseReferences<_$TrackLiteDatabase, $EventsTable, EventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$TrackLiteDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$TrackLiteDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$MetaEntriesTableCreateCompanionBuilder =
    MetaEntriesCompanion Function({
      required String name,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaEntriesTableUpdateCompanionBuilder =
    MetaEntriesCompanion Function({
      Value<String> name,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaEntriesTableFilterComposer
    extends Composer<_$TrackLiteDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaEntriesTableOrderingComposer
    extends Composer<_$TrackLiteDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaEntriesTableAnnotationComposer
    extends Composer<_$TrackLiteDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaEntriesTableTableManager
    extends
        RootTableManager<
          _$TrackLiteDatabase,
          $MetaEntriesTable,
          MetaRow,
          $$MetaEntriesTableFilterComposer,
          $$MetaEntriesTableOrderingComposer,
          $$MetaEntriesTableAnnotationComposer,
          $$MetaEntriesTableCreateCompanionBuilder,
          $$MetaEntriesTableUpdateCompanionBuilder,
          (
            MetaRow,
            BaseReferences<_$TrackLiteDatabase, $MetaEntriesTable, MetaRow>,
          ),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaEntriesTableTableManager(
    _$TrackLiteDatabase db,
    $MetaEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaEntriesCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaEntriesCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaEntriesTable, MetaRow>(table),
                  BaseReferences<
                    _$TrackLiteDatabase,
                    $MetaEntriesTable,
                    MetaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$TrackLiteDatabase,
      $MetaEntriesTable,
      MetaRow,
      $$MetaEntriesTableFilterComposer,
      $$MetaEntriesTableOrderingComposer,
      $$MetaEntriesTableAnnotationComposer,
      $$MetaEntriesTableCreateCompanionBuilder,
      $$MetaEntriesTableUpdateCompanionBuilder,
      (
        MetaRow,
        BaseReferences<_$TrackLiteDatabase, $MetaEntriesTable, MetaRow>,
      ),
      MetaRow,
      PrefetchHooks Function()
    >;
typedef $$UploadsTableCreateCompanionBuilder = UploadsCompanion Function({
  Value<int> id,
  required String trigger,
  required DateTime startedAt,
  required DateTime finishedAt,
  required String outcome,
  Value<int> batches,
  Value<int> events,
  Value<String?> error,
});
typedef $$UploadsTableUpdateCompanionBuilder = UploadsCompanion Function({
  Value<int> id,
  Value<String> trigger,
  Value<DateTime> startedAt,
  Value<DateTime> finishedAt,
  Value<String> outcome,
  Value<int> batches,
  Value<int> events,
  Value<String?> error,
});

class $$UploadsTableFilterComposer
    extends Composer<_$TrackLiteDatabase, $UploadsTable> {
  $$UploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batches => $composableBuilder(
    column: $table.batches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get events => $composableBuilder(
    column: $table.events,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UploadsTableOrderingComposer
    extends Composer<_$TrackLiteDatabase, $UploadsTable> {
  $$UploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batches => $composableBuilder(
    column: $table.batches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get events => $composableBuilder(
    column: $table.events,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UploadsTableAnnotationComposer
    extends Composer<_$TrackLiteDatabase, $UploadsTable> {
  $$UploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get batches =>
      $composableBuilder(column: $table.batches, builder: (column) => column);

  GeneratedColumn<int> get events =>
      $composableBuilder(column: $table.events, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$UploadsTableTableManager
    extends
        RootTableManager<
          _$TrackLiteDatabase,
          $UploadsTable,
          UploadRow,
          $$UploadsTableFilterComposer,
          $$UploadsTableOrderingComposer,
          $$UploadsTableAnnotationComposer,
          $$UploadsTableCreateCompanionBuilder,
          $$UploadsTableUpdateCompanionBuilder,
          (
            UploadRow,
            BaseReferences<_$TrackLiteDatabase, $UploadsTable, UploadRow>,
          ),
          UploadRow,
          PrefetchHooks Function()
        > {
  $$UploadsTableTableManager(_$TrackLiteDatabase db, $UploadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> batches = const Value.absent(),
                Value<int> events = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => UploadsCompanion(
                id: id,
                trigger: trigger,
                startedAt: startedAt,
                finishedAt: finishedAt,
                outcome: outcome,
                batches: batches,
                events: events,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trigger,
                required DateTime startedAt,
                required DateTime finishedAt,
                required String outcome,
                Value<int> batches = const Value.absent(),
                Value<int> events = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => UploadsCompanion.insert(
                id: id,
                trigger: trigger,
                startedAt: startedAt,
                finishedAt: finishedAt,
                outcome: outcome,
                batches: batches,
                events: events,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UploadsTable, UploadRow>(table),
                  BaseReferences<_$TrackLiteDatabase, $UploadsTable, UploadRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$TrackLiteDatabase,
      $UploadsTable,
      UploadRow,
      $$UploadsTableFilterComposer,
      $$UploadsTableOrderingComposer,
      $$UploadsTableAnnotationComposer,
      $$UploadsTableCreateCompanionBuilder,
      $$UploadsTableUpdateCompanionBuilder,
      (
        UploadRow,
        BaseReferences<_$TrackLiteDatabase, $UploadsTable, UploadRow>,
      ),
      UploadRow,
      PrefetchHooks Function()
    >;

class $TrackLiteDatabaseManager {
  final _$TrackLiteDatabase _db;
  $TrackLiteDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db, _db.metaEntries);
  $$UploadsTableTableManager get uploads =>
      $$UploadsTableTableManager(_db, _db.uploads);
}
