import 'package:intl/intl.dart';

/// A price for people: `$12.50` (whole cents in, the currency's symbol and
/// decimals out).
String formatPrice(int cents, String currency) =>
    NumberFormat.simpleCurrency(name: currency).format(cents / 100);
