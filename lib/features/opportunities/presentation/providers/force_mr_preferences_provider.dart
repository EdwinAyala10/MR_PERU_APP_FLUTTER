import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/infrastructure/services/key_value_storage_service.dart';
import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';

final keyValueStorageServiceProvider = Provider<KeyValueStorageService>((ref) {
  return KeyValueStorageServiceImpl();
});

final forceMrPreferencesProvider = StateNotifierProvider<ForceMrPreferencesNotifier, bool>((ref) {
  final storageService = ref.watch(keyValueStorageServiceProvider);
  return ForceMrPreferencesNotifier(storageService);
});

class ForceMrPreferencesNotifier extends StateNotifier<bool> {
  final KeyValueStorageService _storageService;
  static const String _key = 'force_mr_accepted';

  ForceMrPreferencesNotifier(this._storageService) : super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final accepted = await _storageService.getValue<bool>(_key);
    state = accepted ?? false;
  }

  Future<void> setAccepted(bool value) async {
    await _storageService.setKeyValue<bool>(_key, value);
    state = value;
  }

  Future<bool> hasAccepted() async {
    final accepted = await _storageService.getValue<bool>(_key);
    return accepted ?? false;
  }
}
