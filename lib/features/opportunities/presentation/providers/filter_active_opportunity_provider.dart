import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PROVIDERS OF FILTER ACTIVE SCREEN OPPORTUNITY
///
///

final probstartProvider = StateProvider<double>((ref) => 0.0);
final probendProvider = StateProvider<double>((ref) => 0.0);

final startValueProvider = StateProvider<num>((ref) => 0);
final endValueProvider = StateProvider<num>((ref) => 0);

final rangeProbProvider = StateProvider<RangeValues>(
  (ref) => const RangeValues(0, 100),
);

final startDateProvider = StateProvider<DateTime?>((ref) => null);
final endDateProvider = StateProvider<DateTime?>((ref) => null);

final selectedCodesProvider = StateProvider<Set<String>>((ref) => {});

void resetAllProvidersFilterOP(WidgetRef ref) {
  ref.read(probstartProvider.notifier).state = 0.0;
  ref.read(probendProvider.notifier).state = 0.0;

  ref.read(startValueProvider.notifier).state = 0;
  ref.read(endValueProvider.notifier).state = 0;

  ref.read(rangeProbProvider.notifier).state = const RangeValues(0, 100);

  ref.read(startDateProvider.notifier).state = null;
  ref.read(endDateProvider.notifier).state = null;

  ref.read(selectedCodesProvider.notifier).state = {};
}

final searchControllerProvider = Provider((ref) => TextEditingController());
