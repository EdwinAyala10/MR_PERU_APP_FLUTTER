import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PROVIDERS OF FILTER ACTIVE SCREEN OPPORTUNITY
///
///

final probstartProvider = StateProvider<double>((ref) => 0.0);
final probendProvider = StateProvider<double>((ref) => 0.0);

final startValueProvider = StateProvider<num>((ref) => 0);
final endValueProvider = StateProvider<num>((ref) => 0);

final startDateProvider = StateProvider<DateTime?>((ref) => null);
final endDateProvider = StateProvider<DateTime?>((ref) => null);

final selectedCodesProvider = StateProvider<Set<String>>((ref) => {});
