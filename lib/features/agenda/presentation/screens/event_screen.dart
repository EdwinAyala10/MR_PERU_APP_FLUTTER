import 'dart:async';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../../../companies/domain/domain.dart';
import '../../../contacts/domain/domain.dart';
import '../../../contacts/presentation/delegates/search_contact_active_delegate.dart';
import '../../../contacts/presentation/search/search_contacts_active_provider.dart';
import '../../../opportunities/domain/domain.dart';
import '../../../shared/domain/entities/dropdown_option.dart';
import '../../../shared/shared.dart';

import '../../../companies/presentation/search/search_companies_active_provider.dart';
import '../../../companies/presentation/delegates/search_company_active_delegate.dart';

import '../../../opportunities/presentation/search/search_opportunities_active_provider.dart';
import '../../../opportunities/presentation/delegates/search_opportunity_active_delegate.dart';
import '../../../shared/widgets/floating_action_button_custom.dart';
import '../../../shared/widgets/select_custom_form.dart';
import '../../../users/domain/domain.dart';
import '../../../users/presentation/delegates/search_user_delegate.dart';
import '../../../users/presentation/search/search_users_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventScreen extends ConsumerWidget {
  final String eventId;

  const EventScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider(eventId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title:
                Text('${eventState.id == 'new' ? 'Crear' : 'Editar'} Evento',
                style: const TextStyle(
                  fontWeight: FontWeight.w600
                ),),
            /*leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),*/
          ),
          body: eventState.isLoading
              ? const FullScreenLoader()
              : (eventState.event != null
                  ? _EventView(event: eventState.event!)
                  : const Center(
                      child: Text('No se encontro información del evento.'),
                    )),
          //_EventView(event: eventState.event!),
          floatingActionButton: eventState.event != null
              ? FloatingActionButtonCustom(
                  iconData: Icons.save,
                  callOnPressed: () {
                    if (eventState.event == null) return;

                    showLoadingMessage(context);

                    ref
                        .read(eventFormProvider(eventState.event!).notifier)
                        .onFormSubmit()
                        .then((CreateUpdateEventResponse value) {
                      //if ( !value.response ) return;
                      if (value.message != '') {
                        showSnackbar(context, value.message);

                        if (value.response) {
                          //Timer(const Duration(seconds: 3), () {
                          context.push('/agenda');
                          //});
                        }
                      }

                      Navigator.pop(context);

                    });

                  },
                )
              : null),
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
      DropdownOption(id: '', name: 'Selecciona'),
      DropdownOption(id: '01', name: 'Comentario'),
      DropdownOption(id: '02', name: 'Llamada Telefónica'),
      DropdownOption(id: '03', name: 'Reunión'),
      DropdownOption(id: '04', name: 'Visita'),
    ];

    List<DropdownOption> optionsRecordatorio = [
      DropdownOption(id: '1', name: '5 MINUTOS ANTES'),
      DropdownOption(id: '2', name: '15 MINUTOS ANTES'),
      DropdownOption(id: '3', name: '30 MINUTOS ANTES'),
      DropdownOption(id: '4', name: '1 DIA ANTES'),
      DropdownOption(id: '5', name: '1 SEMANA ANTES'),
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
          SelectCustomForm(
            label: 'Tipo de gestión',
            value: eventForm.evntIdTipoGestion.value.trim(),
            callbackChange: (String? newValue) {
              DropdownOption searchTipoGestion = optionsTipoGestion
                  .where((option) => option.id == newValue!)
                  .first;
              ref
                  .read(eventFormProvider(event).notifier)
                  .onTipoGestionChanged(newValue ?? '', searchTipoGestion.name);
            },
            items: optionsTipoGestion,
            errorMessage: eventForm.evntIdTipoGestion.errorMessage,
          ),
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
                    _openSearchCompanies(
                        context, ref, eventForm.evntIdUsuarioResponsable ?? '');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: eventForm.evntRuc.errorMessage != null ? Colors.red : Colors.grey
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventForm.evntRuc.value == ''
                                ? 'Seleccione empresa'
                                : eventForm.evntRazon ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: eventForm.evntRuc.errorMessage != null ? Colors.red : Colors.black
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _openSearchCompanies(context, ref,
                                eventForm.evntIdUsuarioResponsable ?? '');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          eventForm.evntRuc.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    eventForm.evntRuc.errorMessage ?? '',
                    style: TextStyle(color: Colors.red[400], fontSize: 11),
                  ),
                )
              : Container(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Todo el día?',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Switch(
                activeColor: secondaryColor,
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
              Text('Gestión de invitados',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Spacer(),
              Text('Contactos',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.w600)),
              SizedBox(
                width: 14.0,
              ),
              Text('Personal',
                  style: TextStyle(
                      color: secondaryColor, fontWeight: FontWeight.w600)),
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
                  eventForm.arraycontacto!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: eventForm.arraycontacto != null
                              ? List<Widget>.from(
                                  eventForm.arraycontacto!.map((item) => Chip(
                                        backgroundColor:
                                            primaryColor,
                                        deleteIconColor: Colors.white,
                                        label: Text(item.nombre ?? '',
                                            style: const TextStyle(
                                              
                                              color: Colors.white,
                                                fontSize:
                                                    12)),
                                        onDeleted: () {
                                          ref
                                            .read(
                                                eventFormProvider(event)
                                                    .notifier)
                                            .onDeleteContactoChanged(item);
                                        },
                                      )))
                              : [],
                        )
                      : const Text('Seleccione contactos',
                          style: TextStyle(color: Colors.black45)),
                  eventForm.arrayresponsable!.isNotEmpty
                      ? Wrap(
                          spacing: 6.0,
                          children: eventForm.arrayresponsable != null
                              ? List<Widget>.from(eventForm.arrayresponsable!
                                  .map((item) => Chip(
                                        backgroundColor: secondaryColor,
                                        deleteIconColor: Colors.white,
                                        label: Text(item.nombre ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    12)), // Aquí deberías colocar el texto que deseas mostrar en el chip para cada elemento de la lista
                                        onDeleted: () {
                                          ref
                                            .read(
                                                eventFormProvider(event)
                                                    .notifier)
                                            .onDeleteResponsableChanged(item);
                                          // Aquí puedes manejar la eliminación del chip si es necesario
                                        },
                                      )))
                              : [],
                        )
                      : const Text('Seleccione responsable',
                          style: TextStyle(color: Colors.black45)),
                ],
              )),
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
                              title: const Center(
                                  child:
                                      Text('Invitar contactos de la empresa')),
                              onTap: () {
                                Navigator.pop(context);
                                _openSearchContacts(context, ref, eventForm.evntRuc.value);
                              },
                            ),
                            const Divider(),
                            ListTile(
                              title: const Center(
                                  child: Text('Invitar personas de MRPERUSA')),
                              onTap: () {
                                Navigator.pop(context); // Cierra el modal
                                _openSearchUsers(context, ref);
                              },
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            ListTile(
                              title: const Center(
                                child: Text(
                                  'CANCELAR',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
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
          /*const SizedBox(height: 20),
          CustomCompanyField(
            label: 'Email de usuarios externos',
            initialValue: eventForm.evntCorreosExternos ?? '',
            onChanged: ref
                .read(eventFormProvider(event).notifier)
                .onCorreosExternosChanged,
          ),*/
          //const Text('  ingresar emails separado por comas (,)',
          //    style: TextStyle(fontSize: 12, color: Colors.black45)),
          //const SizedBox(height: 30),
          /*const Text(
            'DIRECCIÓN',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),*/
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
                    if (eventForm.evntRuc.value == "") {
                      showSnackbar(context, 'Primero seleccione una empresa');
                      return;
                    }
                    _openSearchOportunities(
                        context, ref, eventForm.evntRuc.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: eventForm.evntIdOportunidad.errorMessage != null ? Colors.red : Colors.grey,
                        
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventForm.evntIdOportunidad.value == ''
                                ? 'Seleccione Oportunidad'
                                : eventForm.evntNombreOportunidad ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    eventForm.evntIdOportunidad.errorMessage !=
                                            null
                                        ? Colors.red[400]
                                        : Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (eventForm.evntRuc.value == "") {
                              showSnackbar(
                                  context, 'Primero seleccione una empresa');
                              return;
                            }
                            _openSearchOportunities(
                                context, ref, eventForm.evntRuc.value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          eventForm.evntIdOportunidad.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    eventForm.evntIdOportunidad.errorMessage ?? '',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                )
              : Container(),
          const SizedBox(height: 10),
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
          .read(eventFormProvider(event).notifier)
          .onOportunidadChanged(opportunity.id, opportunity.oprtNombre);
    });
  }

  void _openSearchCompanies(
      BuildContext context, WidgetRef ref, String dni) async {
    final searchedCompanies = ref.read(searchedCompaniesProvider);
    final searchQuery = ref.read(searchQueryCompaniesProvider);

    showSearch<Company?>(
            query: searchQuery,
            context: context,
            delegate: SearchCompanyDelegate(
                dni: dni,
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

  void _openSearchContacts(BuildContext context, WidgetRef ref, String ruc) async {
    final searchedContacts = ref.read(searchedContactsProvider);
    final searchQuery = ref.read(searchQueryContactsProvider);

    showSearch<Contact?>(
            query: searchQuery,
            context: context,
            delegate: SearchContactDelegate(
              ruc: ruc,
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
