import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_local_active_delegate.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/presentation/search/search_company_locales_active_provider.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/delegates/search_contact_active_delegate.dart';
import 'package:crm_app/features/contacts/presentation/search/search_contacts_active_provider.dart';
import 'package:crm_app/features/location/presentation/providers/location_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/custom_alert_dialog.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/format_distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompanyCheckInScreen extends ConsumerWidget {
  final String id;

  const CompanyCheckInScreen({super.key, required this.id});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyCheckInState = ref.watch(companyCheckInProvider(id));

    List<String> ids = id.split("*");
    String idCheck = ids[0];
    String ruc = ids[1];

    final locationState = ref.watch(locationProvider);
    bool? allowSave = locationState.allowSave;
    double? distanceLocationAddressDiff =
        locationState.distanceLocationAddressDiff;

    bool isButtonAllowSave = distanceLocationAddressDiff >= 0 && allowSave;

    String distanceCalc = distanceLocationAddressDiff >= 0
        ? '(${formatDistance(distanceLocationAddressDiff)})'
        : '';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Crear ${companyCheckInState.id == '01' ? 'Check-In' : 'Check-out'}'),
          /*eading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
        ),
        body: companyCheckInState.isLoading
            ? const FullScreenLoader()
            : _CompanyCheckInView(
                companyCheckIn: companyCheckInState.companyCheckIn!),
        floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.save,
          isDisabled: !isButtonAllowSave,
          callOnPressed: () {
            if (!isButtonAllowSave) {
              print('QUE PASO');

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialogPro(
                      parentContext: context,
                      title: 'Advertencia',
                      message:
                          'Vaya, estás muy lejos de ${companyCheckInState.companyCheckIn?.cchkRazon ?? ''} ${distanceCalc}',
                      buttonText: 'Aceptar');
                },
              );

              return;
            }

            if (companyCheckInState.companyCheckIn == null) return;

            /*if (!allowSave) {
              showSnackbar(context, 'Te encuentras lejos del local (<100 m)');
              return;
            }*/

            ref
                .read(companyCheckInFormProvider(
                        companyCheckInState.companyCheckIn!)
                    .notifier)
                .onFormSubmit()
                .then((CreateUpdateCompanyCheckInResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);
                if (value.response) {
                  print('CHECK STATUS SCREEN: ${idCheck}');

                  ref
                      .watch(companyProvider(ruc).notifier)
                      .updateCheckState(idCheck);

                  //Timer(const Duration(seconds: 3), () {
                  //context.push('/company_detail/${ruc}');

                  ref
                      .read(locationProvider.notifier)
                      .setOffLocationAddressDiff();
                  final locationNotifier = ref.read(locationProvider.notifier);
                  locationNotifier.stopFollowingUser();

                  context.pop();
                  //context.push('/company/${company.ruc}');
                  //});
                }
              }
            });
          },
        ),
      ),
    );
  }
}

class _CompanyCheckInView extends ConsumerStatefulWidget {
  final CompanyCheckIn companyCheckIn;

  const _CompanyCheckInView({Key? key, required this.companyCheckIn})
      : super(key: key);

  @override
  _CompanyCheckInViewState createState() => _CompanyCheckInViewState();
}

class _CompanyCheckInViewState extends ConsumerState<_CompanyCheckInView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final locationNotifier = ref.read(locationProvider.notifier);
      locationNotifier.startFollowingUser();

      ref.read(locationProvider.notifier).setOffLocationAddressDiff();

      print('INICIO START FLLOWING');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //ref.read(locationProvider.notifier).setOffLocationAddressDiff();
      final locationNotifier = ref.read(locationProvider.notifier);
      locationNotifier.stopFollowingUser();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyCheckIn = widget.companyCheckIn;

    return ListView(
      children: [
        const SizedBox(height: 10),
        _CompanyCheckInInformation(companyCheckIn: companyCheckIn),
      ],
    );
  }
}

class _CompanyCheckInInformation extends ConsumerWidget {
  final CompanyCheckIn companyCheckIn;

  const _CompanyCheckInInformation({required this.companyCheckIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyCheckInForm =
        ref.watch(companyCheckInFormProvider(companyCheckIn));

    final locationState = ref.watch(locationProvider);
    LatLng? lastKnownLocation = locationState.lastKnownLocation;
    LatLng? locationAddressDiff = locationState.locationAddressDiff;
    bool? selectedLocationAddressDiff =
        locationState.selectedLocationAddressDiff;
    bool? allowSave = locationState.allowSave;
    double distanceLocationAddressDiff =
        locationState.distanceLocationAddressDiff;

    print('lastKnownLocation: ${lastKnownLocation?.toString()}');
    print('selectedLocationAddressDiff: ${lastKnownLocation?.toString()}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Empresa',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(label: Text(companyCheckInForm.cchkRazon ?? ''))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          selectedLocationAddressDiff
              ? Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: allowSave ? Colors.green : Colors.deepOrange,
                        padding: const EdgeInsets.all(11.0),
                        child: Text(
                          distanceLocationAddressDiff == 0
                              ? 'Estas en el local!'
                              : 'Estas a ${formatDistance(distanceLocationAddressDiff)} de distancia del local',
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        companyCheckInForm.cchkLocalCodigo.errorMessage != null
                            ? Theme.of(context).colorScheme.error
                            : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchCompanyLocales(
                        context, ref, companyCheckInForm.cchkRuc.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              companyCheckInForm.cchkLocalCodigo.errorMessage !=
                                      null
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            companyCheckInForm.cchkLocalCodigo.value == ''
                                ? 'Seleccione local'
                                : companyCheckInForm.cchkLocalNombre ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: companyCheckInForm
                                            .cchkLocalCodigo.errorMessage !=
                                        null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchCompanyLocales(
                                context, ref, companyCheckInForm.cchkRuc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (companyCheckInForm.cchkLocalCodigo.errorMessage != null)
            Text(
              companyCheckInForm.cchkLocalCodigo.errorMessage ?? 'Requerido',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const SizedBox(height: 10),
          TextViewCustom(
              text: companyCheckInForm.cchkCoordenadaLatitud ?? '',
              placeholder: 'Latitud',
              label: 'Latitud Local'),
          TextViewCustom(
              text: companyCheckInForm.cchkCoordenadaLongitud ?? '',
              placeholder: 'Longitud',
              label: 'Longitud Local'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oportunidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: companyCheckInForm.cchkIdOportunidad.errorMessage !=
                            null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchOportunities(
                        context, ref, companyCheckInForm.cchkRuc.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: companyCheckInForm
                                      .cchkIdOportunidad.errorMessage !=
                                  null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            companyCheckInForm.cchkIdOportunidad.value == ''
                                ? 'Seleccione oportunidad'
                                : companyCheckInForm.cchkNombreOportunidad ??
                                    '',
                            //_selectedCompany.isEmpty ? 'Seleccione una empresa' : _selectedCompany,
                            style: TextStyle(
                                fontSize: 16,
                                color: companyCheckInForm
                                            .cchkIdOportunidad.errorMessage !=
                                        null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchOportunities(
                                context, ref, companyCheckInForm.cchkRuc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (companyCheckInForm.cchkIdOportunidad.errorMessage != null)
            Text(
              companyCheckInForm.cchkIdOportunidad.errorMessage ?? 'Requerido',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacto *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        companyCheckInForm.cchkIdContacto.errorMessage != null
                            ? Theme.of(context).colorScheme.error
                            : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchContacts(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: companyCheckInForm
                                      .cchkIdOportunidad.errorMessage !=
                                  null
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            companyCheckInForm.cchkIdContacto.value == ''
                                ? 'Seleccione contacto'
                                : companyCheckInForm.cchkNombreContacto ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: companyCheckInForm
                                            .cchkIdContacto.errorMessage !=
                                        null
                                    ? Theme.of(context).colorScheme.error
                                    : null),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchContacts(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          companyCheckInForm.cchkIdContacto.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    companyCheckInForm.cchkIdContacto.errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: companyCheckInForm.cchkIdComentario.value,
            errorMessage: companyCheckInForm.cchkIdComentario.errorMessage,
            onChanged: ref
                .read(companyCheckInFormProvider(companyCheckIn).notifier)
                .onComentarioChanged,
          ),
          const SizedBox(height: 20),
          const Text(
            'Responsable',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(
                        label: Text(
                            companyCheckInForm.cchkNombreUsuarioResponsable ??
                                ''))
                  ],
                ),
              ),
            ],
          ),

          /*CustomCompanyField(
            label: 'Dirección',
            initialValue: companyCheckInForm.cchkDireccionMapa ?? '',
            onChanged: ref
                .read(companyCheckInFormProvider(companyCheckIn).notifier)
                .onDireccionChanged,
          ),*/
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /*void _openSearch(BuildContext context, WidgetRef ref) async {
    final searchedCompanies = ref.read(searchedCompaniesProvider);
    final searchQuery = ref.read(searchQueryCompaniesProvider);

    showSearch<Company?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyDelegate(
                initialCompanies: searchedCompanies,
                searchCompanies: ref
                    .read(searchedCompaniesProvider.notifier)
                    .searchCompaniesByQuery))
        .then((company) {
      if (company == null) return;

      ref.read(companyCheckInFormProvider(companyCheckIn).notifier).onRucChanged(company.ruc);
      ref.read(companyCheckInFormProvider(companyCheckIn).notifier).onRazonChanged(company.razon);

    });
  }*/

  void _openSearchOportunities(
      BuildContext context, WidgetRef ref, String ruc) async {
    final searchedOpportunities = ref.read(searchedOpportunitiesProvider);
    final searchQuery = ref.read(searchQueryOpportunitiesProvider);

    showSearch<Opportunity?>(
            query: searchQuery,
            context: context,
            delegate: SearchOpportunityDelegate(
                ruc: ruc,
                initialOpportunities: searchedOpportunities,
                searchOpportunities: ref
                    .read(searchedOpportunitiesProvider.notifier)
                    .searchOpportunitiesByQuery))
        .then((opportunity) {
      if (opportunity == null) return;

      ref
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
          .onOportunidadChanged(opportunity.id, opportunity.oprtNombre);
    });
  }

  void _openSearchContacts(BuildContext context, WidgetRef ref) async {
    final searchedContacts = ref.read(searchedContactsProvider);
    final searchQuery = ref.read(searchQueryContactsProvider);

    showSearch<Contact?>(
            query: searchQuery,
            context: context,
            delegate: SearchContactDelegate(
                initialContacts: searchedContacts,
                searchContacts: ref
                    .read(searchedContactsProvider.notifier)
                    .searchContactsByQuery))
        .then((contact) {
      if (contact == null) return;

      ref
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
          .onContactoChanged(contact.id, contact.contactoDesc);
    });
  }

  void _openSearchCompanyLocales(
      BuildContext context, WidgetRef ref, String ruc) async {
    final searchedCompanyLocales = ref.read(searchedCompanyLocalesProvider);
    final searchQuery = ref.read(searchQueryCompanyLocalesProvider);

    showSearch<CompanyLocal?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyLocalDelegate(
                ruc: ruc,
                initialCompanyLocales: searchedCompanyLocales,
                searchCompanyLocales: ref
                    .read(searchedCompanyLocalesProvider.notifier)
                    .searchCompanyLocalesByQuery))
        .then((companyLocal) {
      if (companyLocal == null) return;

      ref
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
          .onLocalChanged(companyLocal.id,
              '${companyLocal.localNombre} ${companyLocal.localDireccion}');

      print('SELECT LOCAL LAT:${companyLocal.coordenadasLatitud}');
      print('SELECT LOCAL LNG:${companyLocal.coordenadasLongitud}');

      ref
          .read(companyCheckInFormProvider(companyCheckIn).notifier)
          .onChangeCoors(companyLocal.coordenadasLatitud ?? '',
              companyLocal.coordenadasLongitud ?? '');

      ref.read(locationProvider.notifier).setCoorsLocationAddressDiff(
          double.parse(companyLocal.coordenadasLatitud ?? '0'),
          double.parse(companyLocal.coordenadasLongitud ?? '0'));

      ref.read(locationProvider.notifier).setOnLocationAddressDiff();
    });
  }
}
