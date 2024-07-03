import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/domain.dart';
import 'resource_details_repository_provider.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resourceDetailsProvider =
    StateNotifierProvider<ResourceDetailsNotifier, ResourceDetailsState>((ref) {
  final resourceDetailsRepository =
      ref.watch(resourceDetailsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return ResourceDetailsNotifier(
    resourceDetailsRepository: resourceDetailsRepository,
    user: user!,
  );
});

class ResourceDetailsNotifier extends StateNotifier<ResourceDetailsState> {
  final ResourceDetailsRepository resourceDetailsRepository;
  final User user;

  ResourceDetailsNotifier({
    required this.resourceDetailsRepository,
    required this.user,
  }) : super(ResourceDetailsState()) {
    //loadResourceDetails();
  }

  /*Future<void> loadResourceDetails() async {
    try {
      /*if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          opportunity: newEmptyOpportunity(),
        );

        return;
      }
      */
      final resourceDetails =
          await resourceDetailsRepository.getResourceDetailsByGroup(state.id);

      state =
          state.copyWith(isLoading: false, resourceDetails: resourceDetails);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
  */

  Future<List<DropdownOption>> loadCatalogById(String groupId) async {
    //state = state.copyWith(isLoading: true);

    List<ResourceDetail> resourceDetails =
        await resourceDetailsRepository.getResourceDetailsByGroup(groupId);

    List<DropdownOption> options = [];

    options.add(DropdownOption('', 'Seleccione...'));

    for (final resourceDetail in resourceDetails) {

      if (resourceDetail.recdCodigo != '00') {
        options.add(
          DropdownOption(resourceDetail.recdCodigo, resourceDetail.recdNombre));
      }
    }

    Map<String, List<DropdownOption>>? mapCatalogs = state.mapCatalogs;

    mapCatalogs ??= {};
    mapCatalogs[groupId] ??= options;

    state = state.copyWith(mapCatalogs: mapCatalogs);

    return options;
  }

  List<DropdownOption>? loadCatalogRead(String groupId) {
    Map<String, List<DropdownOption>>? mapCatalogs = state.mapCatalogs;

    if (mapCatalogs != null && mapCatalogs.containsKey(groupId)) {
      return mapCatalogs[groupId];
    } else {
      return null;
    }
  }
}

class ResourceDetailsState {
  final List<ResourceDetail>? resourceDetails;
  final List<DropdownOption>? catalog;
  final Map<String, List<ResourceDetail>>? mapResourceDetails;
  final Map<String, List<DropdownOption>>? mapCatalogs;
  final bool isLoading;
  final bool isSaving;

  ResourceDetailsState({
    this.resourceDetails,
    this.catalog,
    this.mapResourceDetails,
    this.mapCatalogs,
    this.isLoading = true,
    this.isSaving = false,
  });

  ResourceDetailsState copyWith({
    List<ResourceDetail>? resourceDetails,
    List<DropdownOption>? catalog,
    Map<String, List<ResourceDetail>>? mapResourceDetails,
    Map<String, List<DropdownOption>>? mapCatalogs,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ResourceDetailsState(
        resourceDetails: resourceDetails ?? this.resourceDetails,
        catalog: catalog ?? this.catalog,
        mapResourceDetails: mapResourceDetails ?? this.mapResourceDetails,
        mapCatalogs: mapCatalogs ?? this.mapCatalogs,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}
