import 'dart:developer';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/companies/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../activities/domain/domain.dart';
import '../../../activities/presentation/widgets/item_activity.dart';
import '../../../agenda/domain/domain.dart';
import '../../../agenda/presentation/widgets/item_event.dart';
import '../widgets/item_company_local.dart';
import '../../../contacts/domain/domain.dart';
import '../../../contacts/presentation/widgets/item_contact.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../opportunities/presentation/widgets/item_opportunity.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/floating_action_button_icon_custom.dart';
import '../../domain/domain.dart';
import '../../../shared/shared.dart';

class CompanyDetailScreen extends ConsumerWidget {
  final String companyId;

  const CompanyDetailScreen({Key? key, required this.companyId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(companyId));

    return Scaffold(
      body: companyState.isLoading
          ? const FullScreenLoader()
          : (companyState.company != null
              ? _CompanyDetailView(
                  company: companyState.company!,
                  /*contacts: companySecundaryState.contacts,
                  opportunities: companyState.opportunities,
                  activities: companyState.activities,
                  events: companyState.events,
                  companyLocales: companyState.companyLocales,*/
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No se encontro datos de la empresa'),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Acción cuando se presiona el botón
                          context.pop();
                        },
                        child: const Text('Regresar'),
                      ),
                    ],
                  ),
                )),
    );
  }
}

class _CompanyDetailView extends ConsumerStatefulWidget {
  final Company company;
  /*final List<Contact> contacts;
  final List<Opportunity> opportunities;
  final List<Activity> activities;
  final List<Event> events;
  final List<CompanyLocal> companyLocales;*/

  const _CompanyDetailView({
    required this.company,
    /*required this.contacts,
      required this.opportunities,
      required this.activities,
      required this.events,
      required this.companyLocales*/
  });

  @override
  _CompanyDetailViewState createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref
          .watch(companyProvider(widget.company.ruc).notifier)
          .loadSecundaryDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider(widget.company.ruc));

    TextStyle styleTitle =
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
    TextStyle styleLabel = const TextStyle(
        fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87);
    TextStyle styleContent =
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
    SizedBox spacingHeight = const SizedBox(height: 14);

    return DefaultTabController(
      length: 6, // Ahora tenemos 6 pestañas
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.company.razon,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                    icon: Icon(
                      Icons.info,
                      size: 30,
                    ),
                    text: 'Información'),
                Tab(
                    icon: Icon(
                      Icons.home_work,
                      size: 30,
                    ),
                    text: 'Locales'),
                Tab(
                    icon: Icon(
                      Icons.contacts,
                      size: 30,
                    ),
                    text: 'Contactos'),
                Tab(
                    icon: Icon(
                      Icons.business,
                      size: 30,
                    ),
                    text: 'Oportunidades'),
                Tab(
                  icon: Icon(
                    Icons.event,
                    size: 30,
                  ),
                  text: 'Actividades',
                ),
                Tab(
                    icon: Icon(
                      Icons.event_note,
                      size: 30,
                    ),
                    text: 'Eventos'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push('/company/${widget.company.rucId}');
                },
              ),
              IconButton(
                onPressed: () {
                  /// EXECUTE REMOVE CLIENT
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Alerta'),
                        content: Text(
                          'Esta seguro de dar de baja a la empresa ${widget.company.razon}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              showLoadingMessage(context);
                              final result = await ref
                                  .read(companyProvider(widget.company.ruc)
                                      .notifier)
                                  .removeClient(
                                    widget.company.ruc,
                                  );
                              context.pop();
                              if (result['status']) {
                                ref
                                    .read(companiesProvider.notifier)
                                    .loadNextPage(isRefresh: true);
                                context.pop();
                                context.pop();
                              }
                              if (!result['status']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 3,
                                    backgroundColor: Colors.grey,
                                    content: Text(
                                      result['message'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                                context.pop();
                                context.pop();
                              }
                              // context.pop();
                            },
                            child: const Text('Ok'),
                          )
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete,
                ),
              )
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInformationTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
              _buildLocalesTab(
                  styleTitle,
                  styleLabel,
                  styleContent,
                  spacingHeight,
                  companyState.companyLocales,
                  companyState.isLoadingLocales),
              _buildContactsTab(
                  styleTitle,
                  styleLabel,
                  styleContent,
                  spacingHeight,
                  companyState.contacts,
                  companyState.isLoadingContacts),
              _buildOpportunitiesTab(
                  styleTitle,
                  styleLabel,
                  styleContent,
                  spacingHeight,
                  companyState.opportunities,
                  companyState
                      .isLoadingOpportunities), // Nueva pestaña de oportunidades
              _buildActivitiesTab(
                  styleTitle,
                  styleLabel,
                  styleContent,
                  spacingHeight,
                  companyState.activities,
                  companyState.isLoadingActivities),
              _buildEventsTab(
                  styleTitle,
                  styleLabel,
                  styleContent,
                  spacingHeight,
                  companyState.events,
                  companyState.isLoadingEvents),
            ],
          ),
          floatingActionButton: _itFloatingButton(_currentIndex)),
    );
  }

  Widget _buildInformationTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GENERAL', style: styleTitle),
            spacingHeight,
            _buildInfoField('Nombre de la empresa', widget.company.razon,
                styleLabel, styleContent),
            _buildInfoField('Razon comercial',
                widget.company.razonComercial ?? '', styleLabel, styleContent),
            _buildInfoField(
                'RUC', widget.company.ruc, styleLabel, styleContent),
            _buildInfoField('Rubro', widget.company.nombreRubro ?? '',
                styleLabel, styleContent),
            _buildInfoField('Tipo', widget.company.clienteNombreTipo ?? '',
                styleLabel, styleContent),
            _buildInfoField('Estado', widget.company.clienteNombreEstado ?? '',
                styleLabel, styleContent),
            _buildInfoField(
                'Calificación',
                widget.company.nombreCalificacion ?? '',
                styleLabel,
                styleContent),
            if (widget.company.arrayresponsables != null &&
                widget.company.arrayresponsables!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Responsables', style: styleTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.2,
                    runSpacing: 6,
                    children:
                        widget.company.arrayresponsables!.map((responsable) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          responsable.userreportName ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 10), // Espaciado adicional
            _buildInfoField(
                'Empresa visible para todos',
                widget.company.visibleTodos == "1" ? 'SI' : 'NO',
                styleLabel,
                styleContent),
            widget.company.seguimientoComentario != ""
                ? _buildInfoField(
                    'Comentarios',
                    widget.company.seguimientoComentario ?? '',
                    styleLabel,
                    styleContent)
                : const SizedBox(),
            widget.company.observaciones != ""
                ? _buildInfoField(
                    'Recomendación',
                    widget.company.observaciones ?? '',
                    styleLabel,
                    styleContent)
                : const SizedBox(),
            const SizedBox(height: 20), // Espaciado adicional
            Text('DATOS DE CONTACTO', style: styleTitle),
            spacingHeight,
            widget.company.email != ""
                ? _buildInfoField('Teléfono', widget.company.telefono ?? '',
                    styleLabel, styleContent)
                : const SizedBox(),
            widget.company.email != ""
                ? _buildInfoField('Email', widget.company.email ?? '',
                    styleLabel, styleContent)
                : const SizedBox(),
            _buildInfoField(
                'Web', widget.company.website ?? '-', styleLabel, styleContent),
            const SizedBox(height: 20), // Espaciado adicional
          ],
        ),
      ),
    );
  }

  Future<void> _refreshLocales() async {
    ref
        .watch(companyProvider(widget.company.ruc).notifier)
        .loadSecundaryLocales();
  }

  Future<void> _refreshContacts() async {
    ref
        .watch(companyProvider(widget.company.ruc).notifier)
        .loadSecundaryContacts();
  }

  Future<void> _refreshOpportunities() async {
    ref
        .watch(companyProvider(widget.company.ruc).notifier)
        .loadSecundaryOpportunities();
  }

  Future<void> _refreshActivities() async {
    ref
        .watch(companyProvider(widget.company.ruc).notifier)
        .loadSecundaryActivities();
  }

  Future<void> _refreshEvents() async {
    ref
        .watch(companyProvider(widget.company.ruc).notifier)
        .loadSecundaryEvents();
  }

  Widget _buildLocalesTab(
      TextStyle styleTitle,
      TextStyle styleLabel,
      TextStyle styleContent,
      SizedBox spacingHeight,
      List<CompanyLocal> companyLocales,
      bool isLoading) {
    if (isLoading) {
      return const LoadingModal();
    } else {
      return companyLocales.isNotEmpty
          ? _ListCompanyLocales(
              companyLocales: companyLocales,
              onRefreshCallback: _refreshLocales)
          : NoExistData(
              icon: Icons.business,
              onRefreshCallback: _refreshLocales,
              textCenter: 'No existe locales registrados');
    }
  }

  Widget _buildContactsTab(
      TextStyle styleTitle,
      TextStyle styleLabel,
      TextStyle styleContent,
      SizedBox spacingHeight,
      List<Contact> contacts,
      bool isLoading) {
    if (isLoading) {
      return const LoadingModal();
    } else {
      return contacts.isNotEmpty
          ? _ListContacts(
              contacts: contacts, onRefreshCallback: _refreshContacts)
          : NoExistData(
              icon: Icons.person,
              onRefreshCallback: _refreshContacts,
              textCenter: 'No existe contactos registradas');
    }
  }

  Widget _buildOpportunitiesTab(
      TextStyle styleTitle,
      TextStyle styleLabel,
      TextStyle styleContent,
      SizedBox spacingHeight,
      List<Opportunity> opportunities,
      bool isLoading) {
    if (isLoading) {
      return const LoadingModal();
    } else {
      return opportunities.isNotEmpty
          ? _ListOpportunities(
              opportunities: opportunities,
              onRefreshCallback: _refreshOpportunities)
          : NoExistData(
              icon: Icons.graphic_eq,
              onRefreshCallback: _refreshOpportunities,
              textCenter: 'No existe oportunidades registradas');
    }
  }

  Widget _buildActivitiesTab(
      TextStyle styleTitle,
      TextStyle styleLabel,
      TextStyle styleContent,
      SizedBox spacingHeight,
      List<Activity> activities,
      bool isLoading) {
    if (isLoading) {
      return const LoadingModal();
    } else {
      return activities.isNotEmpty
          ? _ListActivities(
              activities: activities, onRefreshCallback: _refreshActivities)
          : NoExistData(
              icon: Icons.graphic_eq,
              onRefreshCallback: _refreshActivities,
              textCenter: 'No existe actividades registradas');
    }
  }

  Widget _buildEventsTab(
      TextStyle styleTitle,
      TextStyle styleLabel,
      TextStyle styleContent,
      SizedBox spacingHeight,
      List<Event> events,
      bool isLoading) {
    if (isLoading) {
      return const LoadingModal();
    } else {
      return events.isNotEmpty
          ? _ListEvents(events: events, onRefreshCallback: _refreshEvents)
          : NoExistData(
              icon: Icons.graphic_eq,
              onRefreshCallback: _refreshEvents,
              textCenter: 'No existe eventos registrados');
    }
  }

  Widget _buildInfoField(
      String label, String text, TextStyle styleLabel, TextStyle styleContent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: styleLabel),
          const SizedBox(height: 4), // Espaciado vertical
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200], // Color de fondo
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: styleContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _itFloatingButton(currentIndex) {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButtonIconCustom(
          label: widget.company.cchkIdEstadoCheck == '06'
              ? 'CHECK-IN'
              : (widget.company.cchkIdEstadoCheck == null
                  ? 'CHECK-IN'
                  : 'CHECK-OUT'),
          callOnPressed: () async {
            String idCheck = widget.company.cchkIdEstadoCheck == '06'
                ? '01'
                : (widget.company.cchkIdEstadoCheck == null ? '01' : '06');
            ref.read(stateRucProvider.notifier).state = widget.company.ruc;
            final locales =
                ref.read(companyProvider(widget.company.ruc)).companyLocales;
            final totalLocales = locales.length;
            String idLocal = '-';
            String nombreLocal = '-';
            String latLocal = '0.0';
            String lngLocal = '0.0';
            if (totalLocales == 1) {
              idLocal = locales[0].id;
              nombreLocal =
                  '${locales[0].localNombre} ${locales[0].localDireccion}';
              latLocal = locales[0].coordenadasLatitud!;
              lngLocal = locales[0].coordenadasLongitud!;
            }
            String ruc = widget.company.ruc;
            String ids =
                '$idCheck*$ruc*$idLocal*$nombreLocal*$latLocal*$lngLocal';
            log(ids);
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const Dialog(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white38,
                        color: Colors.blueGrey,
                      ),
                    ),
                  );
                });
            await ref.read(companiesProvider.notifier).validateCheckIn(
                  ruc: ruc,
                );
            context.pop();
            if (ref.watch(companiesProvider).isValidateCheckIn) {
              context.push('/company_check_in/$ids');
              return;
            } else {
              log(ref.read(companiesProvider).validationCheckinMessage);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 3,
                  backgroundColor: Colors.grey,
                  content: Text(
                    ref.watch(companiesProvider).validationCheckinMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            // context.push('/company_check_in/$ids');
          },
          iconData: Icons.check_circle_outline_outlined,
        );

      case 1:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              String ruc = widget.company.ruc;
              String ids = 'new*$ruc';
              context.push('/company_local/$ids');
            },
            iconData: Icons.add);

      case 2:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              ref
                  .read(uiProvider.notifier)
                  .onCompanyActivity(widget.company.ruc, widget.company.razon);
              context.push('/contact/new');
            },
            iconData: Icons.add);

      case 3:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              ref
                  .read(uiProvider.notifier)
                  .onCompanyActivity(widget.company.ruc, widget.company.razon);
              context.push('/opportunity/new');
            },
            iconData: Icons.add);

      case 4:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              ref
                  .read(uiProvider.notifier)
                  .onCompanyActivity(widget.company.ruc, widget.company.razon);
              context.push('/activity/new');
            },
            iconData: Icons.add);

      case 5:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              ref
                  .read(uiProvider.notifier)
                  .onCompanyActivity(widget.company.ruc, widget.company.razon);
              context.push('/event/new');
            },
            iconData: Icons.add);

      default:
        return null;
    }
  }
}

class _ListContacts extends StatelessWidget {
  final List<Contact> contacts;
  final Future<void> Function() onRefreshCallback;

  const _ListContacts(
      {required this.contacts, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: contacts.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            final contact = contacts[index];

            return ItemContact(
                contact: contact,
                callbackOnTap: () {
                  context.push('/contact_detail/${contact.id}');
                });
          },
        ),
      ),
    );
  }
}

class _ListCompanyLocales extends StatelessWidget {
  final List<CompanyLocal> companyLocales;
  final Future<void> Function() onRefreshCallback;

  const _ListCompanyLocales(
      {required this.companyLocales, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: companyLocales.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            final companyLocal = companyLocales[index];

            return ItemCompanyLocal(
                companyLocal: companyLocal,
                editCallOnTap: () {
                  String ruc = companyLocal.ruc;
                  String ids = '${companyLocal.id}*$ruc';
                  context.push('/company_local/$ids');
                },
                callbackOnTap: () {
                  context.push('/view-map/${companyLocal.coordenadasGeo}');
                });
          },
        ),
      ),
    );
  }
}

class _ListOpportunities extends StatelessWidget {
  final List<Opportunity> opportunities;
  final Future<void> Function() onRefreshCallback;

  const _ListOpportunities(
      {required this.opportunities, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: opportunities.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            final opportunity = opportunities[index];
            return ItemOpportunity(
                opportunity: opportunity,
                callbackOnTap: () {
                  context.push('/opportunity_detail/${opportunity.id}');
                });
          },
        ),
      ),
    );
  }
}

class _ListActivities extends StatelessWidget {
  final List<Activity> activities;
  final Future<void> Function() onRefreshCallback;

  const _ListActivities(
      {required this.activities, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: activities.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ItemActivity(
                activity: activity,
                callbackOnTap: () {
                  context.push('/activity_detail/${activity.id}');
                });
          },
        ),
      ),
    );
  }
}

class _ListEvents extends StatelessWidget {
  final List<Event> events;
  final Future<void> Function() onRefreshCallback;

  const _ListEvents({required this.events, required this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshCallback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: events.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            final event = events[index];
            return ItemEvent(
                event: event,
                callbackOnTap: () {
                  context.push('/event_detail/${event.id}');
                });
          },
        ),
      ),
    );
  }
}
