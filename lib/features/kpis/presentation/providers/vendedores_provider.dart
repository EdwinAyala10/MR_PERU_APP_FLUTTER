import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import 'kpis_repository_provider.dart';
import '../../../users/domain/domain.dart';

final vendedoresProvider =
    StateNotifierProvider<VendedoresNotifier, VendedoresState>((ref) {
  final kpisRepository = ref.watch(kpisRepositoryProvider);

  return VendedoresNotifier(kpisRepository: kpisRepository);
});

class VendedoresNotifier extends StateNotifier<VendedoresState> {
  final KpisRepository kpisRepository;
  Timer? _debounceTimer;

  VendedoresNotifier({required this.kpisRepository})
      : super(VendedoresState()) {
    loadVendedores('');
  }

  Future<void> loadVendedores(String search) async {
    state = state.copyWith(isLoading: true);

    try {
      final allUsers = await kpisRepository.getUsersByType(search);
      final vendedores = allUsers;

      state = state.copyWith(
        isLoading: false,
        vendedores: vendedores,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void searchVendedores(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadVendedores(query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class VendedoresState {
  final bool isLoading;
  final List<UserMaster> vendedores;

  VendedoresState({
    this.isLoading = false,
    this.vendedores = const [],
  });

  VendedoresState copyWith({
    bool? isLoading,
    List<UserMaster>? vendedores,
  }) {
    return VendedoresState(
      isLoading: isLoading ?? this.isLoading,
      vendedores: vendedores ?? this.vendedores,
    );
  }
}
