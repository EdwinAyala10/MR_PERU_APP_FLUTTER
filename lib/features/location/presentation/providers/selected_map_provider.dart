import '../../domain/domain.dart';
import '../../domain/entities/selected_address.dart';
import 'providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/infrastructure/services/key_value_storage_service.dart';
import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final selectedMapProvider =
    StateNotifierProvider<SelectedMapNotifier, SelectedMapState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();
  final gpsProviderNot = ref.watch(gpsProvider.notifier);
  final locationProviderNot = ref.watch(locationProvider.notifier);
  final placeRepository = ref.read(placesRepositoryProvider);

  return SelectedMapNotifier(
      //authRepository: authRepository,
      gpsProviderNot: gpsProviderNot,
      locationProviderNot: locationProviderNot,
      searchPlaceIdCoors: placeRepository.getSearchPlaceIdByCoors,
      searchPlace: placeRepository.getDetailByPlaceId,
      keyValueStorageService: keyValueStorageService);
});

typedef SearchPlaceIdCoorsCallback = Future<String> Function(String coors);
typedef SearchPlaceCallback = Future<Place> Function(String placeId);

class SelectedMapNotifier extends StateNotifier<SelectedMapState> {
  //final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  final GpsNotifier gpsProviderNot;
  final LocationNotifier locationProviderNot;
  final SearchPlaceIdCoorsCallback searchPlaceIdCoors;
  final SearchPlaceCallback searchPlace;

  SelectedMapNotifier({
    //required this.authRepository,
    required this.gpsProviderNot,
    required this.locationProviderNot,
    required this.keyValueStorageService,
    required this.searchPlaceIdCoors,
    required this.searchPlace,
  }) : super(SelectedMapState());

  void onSelectPlace(Place place) {
    final address = place.shortFormattedAddress;
    final addressComponent = onAddressComponents(place.addressComponents);

    state = state.copyWith(
      address: address,
      location: LatLng(place.location.latitude, place.location.longitude),
      departament: addressComponent.departamento,
      district: addressComponent.distrito,
      province: addressComponent.provincia,
      ubigeo: addressComponent.ubigeo,
    );
  }

  Future searchPlaceByLocation(String locationStr) async {
    final placeId = await searchPlaceIdCoors(locationStr);

    if (placeId != "") {
      final place = await searchPlace(placeId);

      final addressComponent = onAddressComponents(place.addressComponents);

      state = state.copyWith(
        location: LatLng(place.location.latitude, place.location.longitude),
        address: place.formattedAddress,
        departament: addressComponent.departamento,
        district: addressComponent.distrito,
        province: addressComponent.provincia,
        ubigeo: addressComponent.ubigeo,
      );
    }
  }

  SelectedAddress onAddressComponents(
      List<AddressComponent> addressComponents) {
    String? departamento;
    String? provincia;
    String? distrito;
    String? ubigeo;

    for (var component in addressComponents) {
      List<String> types = List<String>.from(component.types);
      if (types.contains('administrative_area_level_1')) {
        departamento = component.longText;
      } else if (types.contains('administrative_area_level_2')) {
        provincia = component.longText;
      } else if (types.contains('locality')) {
        distrito = component.longText;
      } else if (types.contains('postal_code')) {
        ubigeo = component.longText;
      }
    }

    SelectedAddress address = SelectedAddress();

    address.departamento = departamento;
    address.provincia = provincia;
    address.distrito = distrito;
    address.ubigeo = ubigeo;

    return address;
  }

  Future<void> selectedAddressMap(Place? place, LatLng locationCenter) async {
    //if (place != null) {
    //print('EXISTE PLACE SEARCH');
    //onSelectPlace(place);
    //} else {
    //print("No existe place search");
    String locationString =
        '${locationCenter.latitude}, ${locationCenter.longitude}';
    await searchPlaceByLocation(locationString);
    //}
  }

  Future<void> onSelectMapLocation(
      bool isLocation, bool isNew, String id, String module, String input, dynamic entity) async {
    LatLng location;
    if (isLocation) {
      location = await locationProviderNot.currentPosition();

      String locationString = '${location.latitude}, ${location.longitude}';
      await searchPlaceByLocation(locationString);
    } else {
      location = const LatLng(-12.04318, -77.02824);
    }

    state = state.copyWith(
        checkPosition: isLocation,
        isNew: isNew,
        id: id,
        location: location,
        entity: entity,
        module: module,
        input: input,
        stateProcess: 'loading',
        isUpdateAddress: true);
  }

  void onFreeIsUpdateAddress() {
    state = state.copyWith(isUpdateAddress: false);
  }

  void onChangeStateProcess(String stateProcess) {
    state = state.copyWith(stateProcess: stateProcess);
  }

  void onChangeCheckPosition(bool bol) {
    state = state.copyWith(checkPosition: bol);
  }

  void onChangeIsNew(bool bol) {
    state = state.copyWith(isNew: bol);
  }

  void onChangeInput(String input) {
    state = state.copyWith(input: input);
  }

  void onChangeLocation(LatLng location) {
    state = state.copyWith(
      location: location,
    );
  }

  void onChangeUbigeo(String value) {
    state = state.copyWith(
      ubigeo: value,
    );
  }

  void onChangeAddress(String value) {
    state = state.copyWith(
      address: value,
    );
  }

  void onChangeProvince(String value) {
    state = state.copyWith(
      province: value,
    );
  }

  void onChangeDepartament(String value) {
    state = state.copyWith(
      departament: value,
    );
  }

  void onChangeDistrict(String value) {
    state = state.copyWith(
      district: value,
    );
  }
}

class SelectedMapState {
  final bool checkPosition;
  final bool isNew;
  final String id;
  final LatLng? location;
  final String? address;
  final String? ubigeo;
  final String? departament;
  final String? province;
  final String? district;
  final bool isUpdateAddress;
  final String stateProcess;
  final String? module;
  final String? input;
  final dynamic entity;

  SelectedMapState(
      {this.id = '',
      this.isNew = false,
      this.checkPosition = false,
      this.location,
      this.address = '',
      this.ubigeo,
      this.departament,
      this.province,
      this.district,
      this.isUpdateAddress = false,
      this.module,
      this.input,
      this.entity,
      this.stateProcess = 'initial'});

  SelectedMapState copyWith({
    String? id,
    bool? isNew,
    bool? checkPosition,
    LatLng? location,
    String? address,
    String? ubigeo,
    String? departament,
    String? province,
    String? district,
    bool? isUpdateAddress,
    String? stateProcess,
    String? module,
    String? input,
    dynamic entity,
  }) =>
      SelectedMapState(
          id: id ?? this.id,
          isNew: isNew ?? this.isNew,
          checkPosition: checkPosition ?? this.checkPosition,
          ubigeo: ubigeo ?? this.ubigeo,
          location: location ?? this.location,
          address: address ?? this.address,
          departament: departament ?? this.departament,
          province: province ?? this.province,
          district: district ?? this.district,
          isUpdateAddress: isUpdateAddress ?? this.isUpdateAddress,
          module: module ?? this.module,
          entity: entity ?? this.entity,
          input: input ?? this.input,
          stateProcess: stateProcess ?? this.stateProcess);
}
