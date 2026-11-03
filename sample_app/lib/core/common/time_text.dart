import 'package:intl/intl.dart';

/// A UTC time as the device's local clock time with seconds: `14:21:05`
/// (the Dashboard's events and uploads happen seconds apart).
String clockTime(DateTime time) => DateFormat.Hms().format(time.toLocal());
