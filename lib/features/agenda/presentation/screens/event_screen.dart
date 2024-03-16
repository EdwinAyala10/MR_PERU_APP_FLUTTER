import 'dart:async';

import 'package:crm_app/features/agenda/domain/domain.dart';
import 'package:crm_app/features/agenda/presentation/providers/providers.dart';
import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/delegates/search_contact_active_delegate.dart';
import 'package:crm_app/features/contacts/presentation/search/search_contacts_active_provider.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';

import 'package:crm_app/features/companies/presentation/search/search_companies_active_provider.dart';
import 'package:crm_app/features/companies/presentation/delegates/search_company_active_delegate.dart';

import 'package:crm_app/features/opportunities/presentation/search/search_opportunities_active_provider.dart';
import 'package:crm_app/features/opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:crm_app/features/users/presentation/delegates/search_user_delegate.dart';
import 'package:crm_app/features/users/presentation/search/search_users_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventScreen extends ConsumerWidget {
  final String eventId;

  const EventScreen({super.key, required this.eventId});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider(eventId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${eventState.id == 'new' ? 'Crear' : 'Editar'} Evento'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: eventState.isLoading
            ? const FullScreenLoader()
            : _EventView(event: eventState.event!),
        //_EventView(event: eventState.event!),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (eventState.event == null) return;

            ref
                .read(eventFormProvider(eventState.event!).notifier)
                .onFormSubmit()
                .then((CreateUpdateEventResponse value) {
              //if ( !value.response ) return;
              if (value.message != '') {
                showSnackbar(context, value.message);

                if (value.response) {
                  Timer(const Duration(seconds: 3), () {
                    context.push('/agenda');
                  });
                }
              }
            });
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class _EventView extends ConsumerWidget {
  final Event event;

  const _EventView({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _EventInformation(event: event),
      ],
    );
  }
}

class _EventInformation extends ConsumerWidget {
  final Event event;
  const _EventInformation({required this.event});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DropdownOption> optionsTipoGestion = [
      DropdownOption('', '--Seleccione--'),
      DropdownOption('01', 'Comentario'),
      DropdownOption('02', 'Llamada Telefónica'),
      DropdownOption('03', 'Reunión'),
      DropdownOption('04', 'Visita'),
    ];

    List<DropdownOption> optionsRecordatorio = [
      DropdownOption('1', '5 MINUTOS ANTES'),
      DropdownOption('2', '15 MINUTOS ANTES'),
      DropdownOption('3', '30 MINUTOS ANTES'),
      DropdownOption('4', '1 DIA ANTES'),
      DropdownOption('5', '1 SEMANA ANTES'),
    ];

    final eventForm = ref.watch(eventFormProvider(event));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          CustomCompanyField(
            label: 'Asunto *',
            initialValue: eventForm.evntAsunto.value,
            errorMessage: eventForm.evntAsunto.errorMessage,
            onChanged:
                ref.read(eventFormProvider(event).notifier).onAsuntoChanged,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Tipo de gestión',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: eventForm.evntIdTipoGestion!.trim(),
                      onChanged: (String? newValue) {
                        DropdownOption searchTipoGestion = optionsTipoGestion
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(eventFormProvider(event).notifier)
                            .onTipoGestionChanged(
                                newValue ?? '', searchTipoGestion.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      items: optionsTipoGestion.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empresa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchCompanies(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventForm.evntRuc == ''
                                ? 'Seleccione empresa'
                                : eventForm.evntRazon ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchCompanies(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Todo el día?',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Switch(
                value: eventForm.todoDia == "0" ? false : true,
                onChanged: (bool bol) {
                  ref
                      .read(eventFormProvider(event).notifier)
                      .onTodoDiaChanged(bol ? '1' : '0');
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Fecha',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: () => _selectDate(context, ref),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy').format(
                          eventForm.evntFechaInicioEvento ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          eventForm.todoDia == "0"
              ? const SizedBox(height: 10)
              : const SizedBox(),
          eventForm.todoDia == "0"
              ? const Text('Hora inicio',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              : const SizedBox(),
          const SizedBox(height: 6),
          eventForm.todoDia == "0"
              ? GestureDetector(
                  onTap: () => _selectTime(context, ref, 'inicio'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(
                              eventForm.evntHoraInicioEvento != null
                                  ? DateFormat('HH:mm:ss').parse(
                                      eventForm.evntHoraInicioEvento ?? '')
                                  : DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
          eventForm.todoDia == "0"
              ? const SizedBox(height: 10)
              : const SizedBox(),
          eventForm.todoDia == "0"
              ? const Text(
                  'Hora fin',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                )
              : const SizedBox(),
          eventForm.todoDia == "0"
              ? const SizedBox(height: 6)
              : const SizedBox(),
          eventForm.todoDia == "0"
              ? GestureDetector(
                  onTap: () => _selectTime(context, ref, 'fin'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(
                              eventForm.evntHoraFinEvento != null
                                  ? DateFormat('HH:mm:ss')
                                      .parse(eventForm.evntHoraFinEvento ?? '')
                                  : DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Recordatorio de cita',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double
                      .infinity, // Ancho específico para el DropdownButton
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Estilo de borde
                      borderRadius:
                          BorderRadius.circular(5.0), // Bordes redondeados
                    ),
                    child: DropdownButton<String>(
                      value: eventForm.evntIdRecordatorio.toString(),
                      onChanged: (String? newValue) {
                        DropdownOption searchRecordatorio = optionsRecordatorio
                            .where((option) => option.id == newValue!)
                            .first;
                        ref
                            .read(eventFormProvider(event).notifier)
                            .onRecordatorioChanged(int.parse(newValue ?? '1'),
                                searchRecordatorio.name);
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      // Mapeo de las opciones a elementos de menú desplegable
                      items: optionsRecordatorio.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            child: Text(option.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text('INVITADOS',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0)),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text('Gestion de invitados',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Spacer(),
              Text(
                'Contactos', 
                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600)
              ),
              SizedBox(
                width: 14.0,
              ),
              Text(
                'Personal', 
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600)
              ),
              SizedBox(
                width: 6.0,
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          const Text(
            'Para añadir contactos en este evento tienes que seleccionar una empresa previamente',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          
          
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    eventForm.arraycontacto != null ? Wrap(
                      spacing: 6.0,
                      children: eventForm.arraycontacto != null
                      ? List<Widget>.from(eventForm.arraycontacto!.map((item) => Chip(
                        backgroundColor: Colors.amberAccent.shade200,
                        label: Text(item.nombre ?? '', style: const TextStyle( fontSize: 12 )), // Aquí deberías colocar el texto que deseas mostrar en el chip para cada elemento de la lista
                        onDeleted: () {
                          // Aquí puedes manejar la eliminación del chip si es necesario
                        },
                      ))) 
                      : [],
                    ) 
                    : const Text('Seleccione contactos', style: TextStyle( color: Colors.black45 )),
                    eventForm.arrayresponsable != null ? Wrap(
                      spacing: 6.0,
                      children: eventForm.arrayresponsable   != null
                      ? List<Widget>.from(eventForm.arrayresponsable!.map((item) => Chip(
                        backgroundColor: Colors.cyanAccent,
                        label: Text(item.nombre ?? '', style: const TextStyle( fontSize: 12 )), // Aquí deberías colocar el texto que deseas mostrar en el chip para cada elemento de la lista
                        onDeleted: () {
                          // Aquí puedes manejar la eliminación del chip si es necesario
                        },
                      ))) 
                      : [],
                    ) 
                    : const Text('Seleccione responsable', style: TextStyle( color: Colors.black45 )),
                  ],
                )
              ),
              ElevatedButton(
                onPressed: () {

                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        //height: 320,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                'Añadir participantes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Center(
                              child: Text(
                                'Añadir invitados a través de...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            ListTile(
                              title: const Center(child: Text('Invitar contactos de la empresa')),
                              onTap: () {
                                Navigator.pop(context);
                                _openSearchContacts(context, ref);

                              },
                            ),
                            const Divider(),
                            ListTile(
                              title: const Center(child: Text('Invitar personas de MRPERUSA')),
                              onTap: () {
                                Navigator.pop(context); // Cierra el modal
                                _openSearchUsers(context, ref);
                              },
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            ListTile(
                              title: const Center(child: Text('CANCELAR', style: TextStyle( fontWeight: FontWeight.w600 ),),),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Email de usuarios externos',
            initialValue: eventForm.evntCorreosExternos ?? '',
            onChanged: ref
                .read(eventFormProvider(event).notifier)
                .onCorreosExternosChanged,
          ),
          const Text('  ingresar emails separado por comas (,)',
              style: TextStyle(fontSize: 12, color: Colors.black45)),
          const SizedBox(height: 30),
          const Text(
            'DIRECCIÓN',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 30),
          const Text(
            'REFERENCIAS',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oportunidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    _openSearchOportunities(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventForm.evntIdOportunidad == ''
                                ? 'Seleccione Oportunidad'
                                : eventForm.evntNombreOportunidad ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchOportunities(context, ref);
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
          const Text(
            'Responsable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(
                        label: Text(
                      eventForm.evntNombreUsuarioResponsable ?? '-',
                    ))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Comentarios',
            maxLines: 2,
            initialValue: eventForm.evntComentario ?? '',
            onChanged: ref
                .read(eventFormProvider(event).notifier)
                .onComentariosChanged,
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    //print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      ref.read(eventFormProvider(event).notifier).onFechaChanged(picked);
    }
  }

  Future<void> _selectTime(
      BuildContext context, WidgetRef ref, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      String formattedTime = '${picked.toString().substring(10, 15)}:00';

      if (type == 'inicio') {
        ref
            .read(eventFormProvider(event).notifier)
            .onHoraInicioChanged(formattedTime);
      }

      if (type == 'fin') {
        ref
            .read(eventFormProvider(event).notifier)
            .onHoraFinChanged(formattedTime);
      }
    }
  }

  void _openSearchOportunities(BuildContext context, WidgetRef ref) async {
    final searchedOpportunities = ref.read(searchedOpportunitiesProvider);
    final searchQuery = ref.read(searchQueryOpportunitiesProvider);

    showSearch<Opportunity?>(
            query: searchQuery,
            context: context,
            delegate: SearchOpportunityDelegate(
                initialOpportunities: searchedOpportunities,
                searchOpportunities: ref
                    .read(searchedOpportunitiesProvider.notifier)
                    .searchOpportunitiesByQuery))
        .then((opportunity) {
      if (opportunity == null) return;

      ref
          .read(eventFormProvider(event).notifier)
          .onOportunidadChanged(opportunity.id, opportunity.oprtNombre);
    });
  }

  void _openSearchCompanies(BuildContext context, WidgetRef ref) async {
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

      ref
          .read(eventFormProvider(event).notifier)
          .onEmpresaChanged(company.ruc, company.razon);
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

      ref.read(eventFormProvider(event).notifier).onContactoChanged(contact);

    });
  }

  void _openSearchUsers(BuildContext context, WidgetRef ref) async {
    final searchedUsers = ref.read(searchedUsersProvider);
    final searchQuery = ref.read(searchQueryUsersProvider);

    showSearch<UserMaster?>(
            query: searchQuery,
            context: context,
            delegate: SearchUserDelegate(
                initialUsers: searchedUsers,
                searchUsers: ref
                    .read(searchedUsersProvider.notifier)
                    .searchUsersByQuery))
        .then((user) {
      if (user == null) return;

      ref.read(eventFormProvider(event).notifier).onResponsableChanged(user);
    });
  }
}
