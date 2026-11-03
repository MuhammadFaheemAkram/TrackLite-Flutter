import 'package:meta/meta.dart';

/// What the validator decided about one `track()` call.
@internal
sealed class Validation {
  const Validation();
}

/// Store it, under [name] (trimmed).
@internal
final class Valid extends Validation {
  const Valid(this.name);

  final String name;
}

/// Drop it, and count it: [reason] says why, for the debug log.
@internal
final class Rejected extends Validation {
  const Rejected(this.reason);

  final String reason;
}

/// The limits an event must stay within. A real analytics server enforces
/// limits like these; checking them here, at `track()`, means a bad event
/// is rejected once, with a reason in the log, instead of failing every
/// upload that carries it.
@internal
abstract final class EventLimits {
  static const maxNameLength = 64;
  static const maxProperties = 25;
  static const maxKeyLength = 40;
  static const maxStringLength = 255;

  /// Keys starting with this are the SDK's own, for later (`$os`, `$lib`).
  static const reservedPrefix = r'$';
}

/// Checks a `track()` call against [EventLimits]. Pure and total: any
/// input gets an answer, never an exception.
@internal
Validation validateEvent(String name, Map<String, Object> properties) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return const Rejected('the name is blank');
  if (trimmed.length > EventLimits.maxNameLength) {
    return const Rejected(
      'the name is longer than ${EventLimits.maxNameLength} characters',
    );
  }
  if (properties.length > EventLimits.maxProperties) {
    return Rejected(
      '${properties.length} properties (at most ${EventLimits.maxProperties})',
    );
  }
  for (final MapEntry(:key, :value) in properties.entries) {
    if (key.trim().isEmpty) return const Rejected('a property name is blank');
    if (key.length > EventLimits.maxKeyLength) {
      return Rejected(
        'property "$key" has a name longer than '
        '${EventLimits.maxKeyLength} characters',
      );
    }
    if (key.startsWith(EventLimits.reservedPrefix)) {
      return Rejected(
        'property "$key" starts with "${EventLimits.reservedPrefix}", '
        'which is reserved for the SDK',
      );
    }
    final problem = switch (value) {
      String() when value.length > EventLimits.maxStringLength =>
        'is longer than ${EventLimits.maxStringLength} characters',
      String() || bool() => null,
      num() when !value.isFinite => 'is not a finite number ($value)',
      num() => null,
      _ => 'is a ${value.runtimeType} (only String, num and bool)',
    };
    if (problem != null) return Rejected('property "$key" $problem');
  }
  return Valid(trimmed);
}
