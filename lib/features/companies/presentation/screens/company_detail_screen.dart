import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/presentation/widgets/item_event.dart';
import 'package:crm_app/features/companies/presentation/widgets/item_company_local.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/widgets/item_contact.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/item_opportunity.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_icon_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/company_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:go_router/go_router.dart';

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
                  contacts: companyState.contacts!,
                  opportunities: companyState.opportunities!,
                  activities: companyState.activities!,
                  events: companyState.events!,
                  companyLocales: companyState.companyLocales!,
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

class _CompanyDetailView extends StatefulWidget {
  final Company company;
  final List<Contact> contacts;
  final List<Opportunity> opportunities;
  final List<Activity> activities;
  final List<Event> events;
  final List<CompanyLocal> companyLocales;

  const _CompanyDetailView(
      {required this.company,
      required this.contacts,
      required this.opportunities,
      required this.activities,
      required this.events,
      required this.companyLocales});

  @override
  State<_CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<_CompanyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
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
            title: Text(widget.company.razon,
                style: const TextStyle(fontSize: 16)),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.info), text: 'Información'),
                Tab(icon: Icon(Icons.home_work), text: 'Locales'),
                Tab(icon: Icon(Icons.contacts), text: 'Contactos'),
                Tab(icon: Icon(Icons.business), text: 'Oportunidades'),
                Tab(icon: Icon(Icons.event), text: 'Actividades'),
                Tab(icon: Icon(Icons.event_note), text: 'Eventos'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push('/company/${widget.company.rucId}');
                },
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInformationTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
              _buildLocalesTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
              _buildContactsTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
              _buildOpportunitiesTab(styleTitle, styleLabel, styleContent,
                  spacingHeight), // Nueva pestaña de oportunidades
              _buildActivitiesTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
              _buildEventsTab(
                  styleTitle, styleLabel, styleContent, spacingHeight),
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
            _buildInfoField(
                'RUC', widget.company.ruc, styleLabel, styleContent),
            _buildInfoField('Tipo', widget.company.clienteNombreTipo ?? '',
                styleLabel, styleContent),
            _buildInfoField('Estado', widget.company.clienteNombreEstado ?? '',
                styleLabel, styleContent),
            _buildInfoField('Calificación', widget.company.calificacion ?? '',
                styleLabel, styleContent),
            if (widget.company.arrayresponsables != null &&
                widget.company.arrayresponsables!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Responsables', style: styleTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        widget.company.arrayresponsables!.map((responsable) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
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
            const SizedBox(height: 20), // Espaciado adicional
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
            _buildInfoField('Teléfono', widget.company.telefono ?? '',
                styleLabel, styleContent),
            widget.company.email != ""
                ? _buildInfoField('Email', widget.company.email ?? '',
                    styleLabel, styleContent)
                : const SizedBox(),
            widget.company.email != ""
                ? _buildInfoField('Web', widget.company.website ?? '',
                    styleLabel, styleContent)
                : const SizedBox(),
            const SizedBox(height: 20), // Espaciado adicional
          ],
        ),
      ),
    );
  }

  Widget _buildLocalesTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return widget.companyLocales.isNotEmpty
        ? _ListCompanyLocales(companyLocales: widget.companyLocales)
        : _NoExistData(description: 'No existe locales registrados');
  }

  Widget _buildContactsTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return widget.contacts.isNotEmpty
        ? _ListContacts(contacts: widget.contacts)
        : _NoExistData(description: 'No existe contactos registradas');
  }

  Widget _buildOpportunitiesTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return widget.opportunities.isNotEmpty
        ? _ListOpportunities(opportunities: widget.opportunities)
        : _NoExistData(description: 'No existe oportunidades registradas');
  }

  Widget _buildActivitiesTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return widget.activities.isNotEmpty
        ? _ListActivities(activities: widget.activities)
        : _NoExistData(description: 'No existe actividades registradas');
  }

  Widget _buildEventsTab(TextStyle styleTitle, TextStyle styleLabel,
      TextStyle styleContent, SizedBox spacingHeight) {
    return widget.events.isNotEmpty
        ? _ListEvents(events: widget.events)
        : _NoExistData(description: 'No existe eventos registradas');
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
            callOnPressed: () {
              String idCheck = widget.company.cchkIdEstadoCheck == '06'
                  ? '01'
                  : (widget.company.cchkIdEstadoCheck == null ? '01' : '06');
              String ruc = widget.company.ruc;
              String ids = '${idCheck}*${ruc}';
              context.push('/company_check_in/${ids}');
            },
            iconData: Icons.check_circle_outline_outlined);
      case 1:
        return FloatingActionButtonCustom(
            callOnPressed: () {
              String ruc = widget.company.ruc;
              String ids = 'new*${ruc}';
              context.push('/company_local/${ids}');
            },
            iconData: Icons.add);

      default:
        return null;
    }
  }
}

class _ListContacts extends StatelessWidget {
  final List<Contact> contacts;
  const _ListContacts({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: contacts.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final contact = contacts[index];

          return ItemContact(
              contact: contact,
              callbackOnTap: () {
                context.push('/contact/${contact.id}');
              });
        },
      ),
    );
  }
}

class _ListCompanyLocales extends StatelessWidget {
  final List<CompanyLocal> companyLocales;
  const _ListCompanyLocales({super.key, required this.companyLocales});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: companyLocales.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final companyLocal = companyLocales[index];

          return ItemCompanyLocal(
              companyLocal: companyLocal,
              callbackOnTap: () {
                context.push('/view-map/${companyLocal.coordenadasGeo}');
              });
        },
      ),
    );
  }
}

class _ListOpportunities extends StatelessWidget {
  final List<Opportunity> opportunities;

  const _ListOpportunities({super.key, required this.opportunities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: opportunities.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final opportunity = opportunities[index];
          return ItemOpportunity(
              opportunity: opportunity,
              callbackOnTap: () {
                context.push('/opportunity/${opportunity.id}');
              });
        },
      ),
    );
  }
}

class _ListActivities extends StatelessWidget {
  final List<Activity> activities;

  const _ListActivities({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ItemActivity(
              activity: activity,
              callbackOnTap: () {
                context.push('/activity/${activity.id}');
              });
        },
      ),
    );
  }
}

class _ListEvents extends StatelessWidget {
  final List<Event> events;

  const _ListEvents({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        itemCount: events.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final event = events[index];
          return ItemEvent(
              event: event,
              callbackOnTap: () {
                context.push('/event/${event.id}');
              });
        },
      ),
    );
  }
}

class _NoExistData extends StatelessWidget {
  String description;

  _NoExistData({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.extension_outlined,
          size: 100,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: Text(
            description,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}
