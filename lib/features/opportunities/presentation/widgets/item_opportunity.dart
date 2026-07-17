import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/contacts/domain/domain.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:crm_app/features/shared/presentation/providers/send_whatsapp_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/domain.dart';

class ItemOpportunity extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  final Function()? callbackOnTap;

  const ItemOpportunity({
    super.key,
    required this.opportunity,
    required this.callbackOnTap,
  });

  @override
  ConsumerState<ItemOpportunity> createState() => _ItemOpportunityState();
}

class _ItemOpportunityState extends ConsumerState<ItemOpportunity> {
  ({Color? background, Color? border})? _staleColors(Opportunity opportunity) {
    final hasActivity = (opportunity.actiIdTipoGestion ?? '').isNotEmpty &&
        (opportunity.actiFechaRegistro ?? '').isNotEmpty;

    if (!hasActivity) {
      return (
        background: const Color(0xFFFFFDE7),
        border: const Color(0xFFFFEB3B),
      );
    }

    final lastActivityDate =
        DateTime.tryParse(opportunity.actiFechaRegistro ?? '');
    if (lastActivityDate == null) return null;

    final daysWithoutActivity =
        DateTime.now().difference(lastActivityDate).inDays;

    if (daysWithoutActivity > 15) {
      return (
        background: const Color(0xFFFFEBEE),
        border: const Color(0xFFEF5350),
      );
    }

    if (daysWithoutActivity > 7) {
      return (
        background: const Color(0xFFFFF3E0),
        border: const Color(0xFFFF9800),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // El widget siempre pinta un card de EMPRESA con su lista de
    // oportunidades. Si llega una oportunidad suelta (flujos que aún no vienen
    // agrupados), se pinta como un grupo de una sola oportunidad para que el
    // widget nunca se comporte distinto según quién lo alimente.
    final grupo = widget.opportunity.oportunidadesDelGrupo;
    final opportunities = (grupo != null && grupo.isNotEmpty)
        ? grupo
        : [widget.opportunity];
    print('ITEM_OPPORTUNITY: ${widget.opportunity.razon} -> ${opportunities.length} oportunidades: ${opportunities.map((o) => o.id).join(",")}');
    return _buildGroupCard(opportunities);
  }

  Widget _buildGroupCard(List<Opportunity> opportunities) {
    final firstOpportunity = opportunities.first;
    final staleColors = _staleColors(firstOpportunity);

    // Se mantienen cargados los contactos de la empresa para que, al abrir el
    // correo, la pantalla de compose ya tenga el contacto y prellene el correo
    // principal (carga en segundo plano, sin fetch al hacer clic).
    for (final o in _distinctContacts(opportunities)) {
      ref.watch(contactProvider(o.contactId ?? ''));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: staleColors != null
          ? BoxDecoration(
              color: staleColors.background,
              border: Border.all(color: staleColors.border!, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            )
          : BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstOpportunity.razon ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if ((firstOpportunity.oprtLocalNombre ?? '').isNotEmpty)
                        Text(
                          firstOpportunity.oprtLocalNombre ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      firstOpportunity.oprtPrimeraFechaRegistro ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      firstOpportunity.nombrePrimeroUsuarioResponsable ?? '',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._buildGroupRows(opportunities),
          if (_distinctContacts(opportunities).isNotEmpty)
            _buildActionRow(opportunities),
        ],
      ),
    );
  }

  List<Widget> _buildGroupRows(List<Opportunity> opportunities) {
    return opportunities.asMap().entries.map((entry) {
      final index = entry.key;
      final opportunity = entry.value;
      final isLast = index == opportunities.length - 1;

      return Container(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
        ),
        child: InkWell(
          onTap: () {
            // Sin importar qué equipo se toque dentro del card de la
            // empresa, el detalle siempre abre en el primero del grupo; el
            // selector de arriba permite saltar a los demás equipos.
            final target = opportunities.first;
            ref.read(selectOpportunity.notifier).state = target;
            ref.read(selectedOp.notifier).state = target;
            ref.read(currentOpportunityShowAllProvider.notifier).state = false;
            ref.read(currentOpportunityDetailTabProvider.notifier).state = 0;
            ref.read(currentOpportunityGroupProvider.notifier).state =
                opportunities;
            context.push('/opportunity_detail/${target.id}');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.work_rounded,
                  color: secondaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((opportunity.oprtNombreContacto ?? '').isNotEmpty)
                      Text(
                        opportunity.oprtNombreContacto ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      'Equipo(s): ${opportunity.oprtNombre}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    Text(opportunity.oprtNobbreEstadoOportunidad ?? ''),
                    if ((opportunity.localDistrito ?? '').isNotEmpty)
                      Text(
                        opportunity.localDistrito ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 2),
                    if ((opportunity.actiComentario ?? '').isNotEmpty ||
                        (opportunity.actiNombreTipoGestion ?? '').isNotEmpty)
                      Text(
                        'Ult.act: ${(opportunity.actiComentario ?? '').isNotEmpty ? opportunity.actiComentario : opportunity.actiNombreTipoGestion ?? ''}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((opportunity.actiFechaRegistro ?? '').isNotEmpty)
                       Row(
                         children: [
                           const Icon(Icons.calendar_month, size: 14),
                           const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              opportunity.actiFechaRegistro ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
               const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${opportunity.oprtProbabilidad ?? ''}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${opportunity.oprtValor == '.00' ? '0.00' : opportunity.oprtValor}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Contactos distintos dentro de la empresa. Cada oportunidad trae su
  /// contacto (CONTACTO_ID / CONTACTO_DESC), así que se deduplica por
  /// contactId y se conserva la oportunidad asociada para dar contexto a la
  /// acción (llamada / whatsapp / correo).
  List<Opportunity> _distinctContacts(List<Opportunity> opportunities) {
    final Map<String, Opportunity> porContacto = {};
    final List<Opportunity> orden = [];
    for (final o in opportunities) {
      final id = (o.contactId ?? '').trim();
      if (id.isEmpty) continue;
      if (!porContacto.containsKey(id)) {
        porContacto[id] = o;
        orden.add(o);
      }
    }
    return orden;
  }

  Widget _buildActionRow(List<Opportunity> opportunities) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () =>
                _handleContactAction(opportunities, _OppAction.call),
            color: Colors.blueAccent,
            icon: const Icon(Icons.call, size: 30),
          ),
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            onTap: () =>
                _handleContactAction(opportunities, _OppAction.whatsapp),
            child: Image.asset(
              'assets/images/icon_whatsapp.png',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            onTap: () =>
                _handleContactAction(opportunities, _OppAction.email),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF00A8DD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.email, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Al presionar una acción: si la empresa tiene un solo contacto, se ejecuta
  /// directo; si tiene varios, se abre el selector de contacto y luego se
  /// ejecuta la acción con el contacto elegido.
  Future<void> _handleContactAction(
    List<Opportunity> opportunities,
    _OppAction action,
  ) async {
    final contactos = _distinctContacts(opportunities);
    if (contactos.isEmpty) return;

    Opportunity? elegido = contactos.first;
    if (contactos.length > 1) {
      elegido = await _selectContact(contactos);
      if (elegido == null) return; // Canceló
    }
    if (!mounted) return;

    // La actividad que se registre debe quedar asociada a TODAS las
    // oportunidades de la empresa agrupada (no solo a la del contacto
    // elegido), usando el mismo campo que ya trae la API para listas de ids
    // (OPRT_ID_OPORTUNIDAD_IN).
    elegido.oprtIdOportunidadIn = _joinedOpportunityIds(opportunities);

    // Se arma el contacto con los datos que ya trae la oportunidad (id,
    // nombre, teléfono, ruc, razón) sin ir a la red, para que la acción sea
    // inmediata. La pantalla de correo carga el contacto completo por id.
    final contact = _contactFromOpportunity(elegido);

    switch (action) {
      case _OppAction.call:
        _runCall(contact, elegido);
        break;
      case _OppAction.whatsapp:
        _runWhatsapp(contact, elegido);
        break;
      case _OppAction.email:
        _runEmail(contact, elegido);
        break;
    }
  }

  /// Ids únicos de todas las oportunidades del grupo (empresa), separados por
  /// coma, para que la actividad quede asociada a todas ellas.
  String _joinedOpportunityIds(List<Opportunity> opportunities) {
    final ids = <String>{};
    for (final o in opportunities) {
      final id = o.id.trim();
      if (id.isNotEmpty) ids.add(id);
    }
    return ids.join(',');
  }

  Contact _contactFromOpportunity(Opportunity o) => Contact(
        id: o.contactId ?? '',
        ruc: o.oprtRuc ?? '',
        razon: o.razon,
        contactoTitulo: '',
        contactoDesc: o.oprtNombreContacto ?? '',
        contactoCargo: '',
        contactoTelefonoc: o.contacTelefono ?? '',
        contactoEmail: '',
      );

  /// Ventana previa "Seleccione contacto" (dropdown). Devuelve la oportunidad
  /// del contacto elegido o null si se cancela.
  Future<Opportunity?> _selectContact(List<Opportunity> contactos) {
    Opportunity seleccion = contactos.first;
    return showDialog<Opportunity>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccione contacto'),
              content: DropdownButton<Opportunity>(
                isExpanded: true,
                value: seleccion,
                items: contactos
                    .map(
                      (o) => DropdownMenuItem<Opportunity>(
                        value: o,
                        child: Text(
                          (o.oprtNombreContacto ?? '').isNotEmpty
                              ? o.oprtNombreContacto!
                              : (o.contactId ?? ''),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setStateDialog(() => seleccion = value);
                },
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(seleccion),
                  child: const Text('Siguiente'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _runCall(Contact contact, Opportunity opportunity) {
    ref.read(selectOpportunity.notifier).state = null;
    ref.read(selectOpportunity.notifier).state = opportunity;
    context
        .push(
      '/activity_post_call/${contact.id}/${agregarPrefijoPeru(contact.contactoTelefonoc)}',
    )
        .then((v) {
      ref.read(selectOpportunity.notifier).state = null;
    });
  }

  void _runWhatsapp(Contact contact, Opportunity opportunity) {
    ref.read(sendWhatsappProvider.notifier).initialSend(
          contact,
          agregarPrefijoPeru(contact.contactoTelefonoc),
          opportunity: opportunity,
        );
    context.push('/text');
  }

  void _runEmail(Contact contact, Opportunity opportunity) {
    // Las claves se guardan sin bloquear la navegación (se leen recién al
    // enviar el correo). El push es síncrono, igual que llamada/whatsapp, para
    // que abra el correo del contacto seleccionado de inmediato.
    KeyValueStorageServiceImpl().setKeyValue<String>(
      'email_return_route',
      '/opportunities',
    );
    KeyValueStorageServiceImpl().setKeyValue<String>(
      'email_opportunity_id',
      (opportunity.oprtIdOportunidadIn ?? '').trim().isNotEmpty
          ? opportunity.oprtIdOportunidadIn!
          : opportunity.id,
    );

    context.push('/email_compose/${contact.id}');
  }
}

enum _OppAction { call, whatsapp, email }
