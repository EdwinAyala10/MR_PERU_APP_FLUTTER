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
  final Future<void> Function(
    Opportunity tappedOpportunity,
    List<Opportunity> group,
  )? callbackOnTap;

  const ItemOpportunity({
    super.key,
    required this.opportunity,
    this.callbackOnTap,
  });

  @override
  ConsumerState<ItemOpportunity> createState() => _ItemOpportunityState();
}

class _ItemOpportunityState extends ConsumerState<ItemOpportunity> {
  bool _isOpeningDetail = false;

  /// Resuelve el grupo a sembrar priorizando el caché de la misma sección.
  /// El caché [companyGroupCacheProvider] se llena cuando se visita un detalle
  /// (no por prefetch masivo en la lista, que saturaba y hacía perder taps).
  /// Si el caché aún no está listo, usa el grupo parcial recibido de la lista.
  List<Opportunity> _resolveSeedGroup(
    Opportunity tapped,
    List<Opportunity> fallback,
  ) {
    final currentType = ref.read(opportunitiesProvider).typeOpportunity;
    final sectionType = resolveOpportunitySectionType(
      preferredType: currentType,
      reference: tapped,
    );
    final ruc = tapped.oprtRuc ?? '';
    final cached = ref.read(companyGroupCacheProvider)[
      companyGroupCacheKey(ruc, sectionType)
    ];
    if (cached == null || cached.isEmpty) {
      final fullGroup = widget.opportunity.oportunidadesDelGrupo;
      if (fullGroup != null && fullGroup.isNotEmpty) {
        return normalizeOpportunityGroup(fullGroup);
      }
      return normalizeOpportunityGroup(fallback);
    }

    return normalizeOpportunityGroup(cached);
  }

  Future<void> _handleOpportunityTap(
    Opportunity tappedOpportunity,
    List<Opportunity> opportunities,
  ) async {
    if (_isOpeningDetail) return;

    // Cerrar teclado inmediatamente antes de cualquier navegación
    FocusScope.of(context).unfocus();

    _isOpeningDetail = true;

    try {
      // Se prioriza el grupo completo cacheado (todos los estados). Si el
      // prefetch aún no terminó, se usa el grupo parcial y el detalle lo
      // completa en segundo plano.
      final seedGroup = _resolveSeedGroup(tappedOpportunity, opportunities);

      // Flujo con callback (desde la pantalla de oportunidades): se delega
      // la siembra de providers y el push, ya con el grupo completo.
      if (widget.callbackOnTap != null) {
        await widget.callbackOnTap!(tappedOpportunity, seedGroup);
        return;
      }

      // Flujo sin callback (dashboard/company/kpi): sin importar qué equipo
      // se toque dentro del card de la empresa, el detalle siempre abre en
      // el primero del grupo; el selector de arriba permite saltar a los
      // demás equipos. Navegación instantánea, sin diálogo de carga.
      final target = seedGroup.first;

      ref.read(selectOpportunity.notifier).state = target;
      ref.read(selectedOp.notifier).state = target;
      ref.read(currentOpportunityShowAllProvider.notifier).state = false;
      ref.read(currentOpportunityDetailTabProvider.notifier).state = 0;
      ref.read(currentOpportunityGroupProvider.notifier).state =
          normalizeOpportunityGroup(seedGroup);
      await context.push('/opportunity_detail/${target.id}');
    } finally {
      if (mounted) {
        _isOpeningDetail = false;
      }
    }
  }

  Future<void> _refreshOpportunitiesList() async {
    final notifier = ref.read(opportunitiesProvider.notifier);
    final currentType = ref.read(opportunitiesProvider).typeOpportunity;
    notifier.clearOpList();
    if (currentType.isEmpty) {
      await notifier.loadNextPage(isRefresh: true);
      return;
    }
    await notifier.loadNextPageByType(isRefresh: true);
  }

  ({Color? background, Color? border})? _staleColors(Opportunity opportunity) {
    final hasActivity = (opportunity.actiIdTipoGestion ?? '').isNotEmpty &&
        (opportunity.actiFechaRegistro ?? '').isNotEmpty;
    final activityDays = int.tryParse(
      (opportunity.actiFechaRegistroDias ?? '').trim(),
    );

    if (!hasActivity) {
      if ((activityDays ?? 0) > 15) {
        return (
          background: const Color(0xFFFFEBEE),
          border: const Color(0xFFEF5350),
        );
      }

      return (
        background: const Color(0xFFFFFDE7),
        border: const Color(0xFFFFEB3B),
      );
    }

    if ((activityDays ?? 0) > 15) {
      return (
        background: const Color(0xFFFFEBEE),
        border: const Color(0xFFEF5350),
      );
    }

    if ((activityDays ?? 0) >= 8) {
      return (
        background: const Color(0xFFFFFDE7),
        border: const Color(0xFFFFEB3B),
      );
    }

    return null;
  }

  ({Color background, Color text}) _lastActivityBadgeColors(
    Opportunity opportunity,
  ) {
    final staleColors = _staleColors(opportunity);
    if (staleColors?.border == const Color(0xFFEF5350)) {
      return (
        background: staleColors?.background ?? Colors.white,
        text: Colors.blue,
      );
    }

    if (staleColors != null) {
      return (
        background: staleColors.background ?? Colors.white,
        text: Colors.red,
      );
    }

    return (
      background: Colors.white,
      text: const Color(0xFF649C9A),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El widget siempre pinta un card de EMPRESA con su lista de
    // oportunidades. Si llega una oportunidad suelta (flujos que aún no vienen
    // agrupados), se pinta como un grupo de una sola oportunidad para que el
    // widget nunca se comporte distinto según quién lo alimente.
    final grupo = widget.opportunity.visibleOportunidadesDelGrupo ??
        widget.opportunity.oportunidadesDelGrupo;
    final opportunities =
        (grupo != null && grupo.isNotEmpty) ? grupo : [widget.opportunity];
    return _buildGroupCard(opportunities);
  }

  Widget _buildGroupCard(List<Opportunity> opportunities) {
    final firstOpportunity = opportunities.first;
    final isSingleOpportunity = opportunities.length == 1;
    final firstStaleColors = _staleColors(firstOpportunity);
    final lastStaleColors = _staleColors(opportunities.last);
    final hasActions = _distinctContacts(opportunities).isNotEmpty;

    // Se mantienen cargados los contactos de la empresa para que, al abrir el
    // correo, la pantalla de compose ya tenga el contacto y prellene el correo
    // principal (carga en segundo plano, sin fetch al hacer clic).
    for (final o in _distinctContacts(opportunities)) {
      ref.watch(contactProvider(o.contactId ?? ''));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: isSingleOpportunity && firstStaleColors != null
          ? BoxDecoration(
              color: firstStaleColors.background,
              border: Border.all(color: firstStaleColors.border!, width: 1.5),
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
          Container(
            decoration: !isSingleOpportunity && firstStaleColors != null
                ? BoxDecoration(
                    color: firstStaleColors.background,
                    border: Border(
                      top: BorderSide(
                        color: firstStaleColors.border!,
                        width: 1.5,
                      ),
                      left: BorderSide(
                        color: firstStaleColors.border!,
                        width: 1.5,
                      ),
                      right: BorderSide(
                        color: firstStaleColors.border!,
                        width: 1.5,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  )
                : null,
            child: Padding(
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
          ),
          ..._buildGroupRows(
            opportunities,
            isSingleOpportunity: isSingleOpportunity,
            hasActionRow: hasActions,
          ),
          if (hasActions)
            _buildActionRow(
              opportunities,
              isSingleOpportunity: isSingleOpportunity,
              staleColors: !isSingleOpportunity ? lastStaleColors : null,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupRows(
    List<Opportunity> opportunities, {
    required bool isSingleOpportunity,
    required bool hasActionRow,
  }) {
    return opportunities.asMap().entries.map((entry) {
      final index = entry.key;
      final opportunity = entry.value;
      final isLast = index == opportunities.length - 1;
      final isFirst = index == 0;
      final staleColors = _staleColors(opportunity);
      final previousStaleColors =
          index > 0 ? _staleColors(opportunities[index - 1]) : null;
      final nextStaleColors =
          !isLast ? _staleColors(opportunities[index + 1]) : null;
      final startsColoredSegment = staleColors != null &&
          !isFirst &&
          previousStaleColors?.border != staleColors.border;
      final endsColoredSegment = staleColors != null &&
          (isLast || nextStaleColors?.border != staleColors.border);

      Border? rowBorder;
      if (!isSingleOpportunity && staleColors != null) {
        rowBorder = Border(
          left: BorderSide(color: staleColors.border!, width: 1.5),
          right: BorderSide(color: staleColors.border!, width: 1.5),
          top: startsColoredSegment
              ? BorderSide(color: staleColors.border!, width: 1.5)
              : BorderSide.none,
          bottom: isLast
              ? (hasActionRow
                  ? BorderSide.none
                  : BorderSide(color: staleColors.border!, width: 1.5))
              : BorderSide(
                  color: staleColors.border!,
                  width: 1,
                ),
        );
      } else if (!isLast) {
        rowBorder = Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        );
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleOpportunityTap(opportunity, opportunities),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
          decoration: BoxDecoration(
            color: !isSingleOpportunity ? staleColors?.background : null,
            border: rowBorder,
          ),
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
                      opportunity.oprtNombre,
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
                      Builder(
                        builder: (context) {
                          final badgeColors =
                              _lastActivityBadgeColors(opportunity);
                          return Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Ult.act: ${(opportunity.actiComentario ?? '').isNotEmpty ? opportunity.actiComentario : opportunity.actiNombreTipoGestion ?? ''}',
                              style: TextStyle(
                                color: badgeColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
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

  Widget _buildActionRow(
    List<Opportunity> opportunities, {
    required bool isSingleOpportunity,
    required ({Color? background, Color? border})? staleColors,
  }) {
    return Container(
      decoration: !isSingleOpportunity && staleColors != null
          ? BoxDecoration(
              color: staleColors.background,
              border: Border(
                left: BorderSide(color: staleColors.border!, width: 1.5),
                right: BorderSide(color: staleColors.border!, width: 1.5),
                bottom: BorderSide(color: staleColors.border!, width: 1.5),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            )
          : null,
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
            onTap: () => _handleContactAction(opportunities, _OppAction.email),
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

    // WhatsApp debe mantenerse asociado a una sola oportunidad, como estaba
    // antes de agrupar la UI. Solo correo mantiene la asociación múltiple del
    // grupo cuando corresponde.
    if (action == _OppAction.email) {
      elegido.oprtIdOportunidadIn = _joinedOpportunityIds(opportunities);
    } else {
      elegido.oprtIdOportunidadIn = '';
    }

    // Se arma el contacto con los datos que ya trae la oportunidad (id,
    // nombre, teléfono, ruc, razón) sin ir a la red, para que la acción sea
    // inmediata. La pantalla de correo carga el contacto completo por id.
    final contact = _contactFromOpportunity(elegido);
    ref.read(currentOpportunityGroupProvider.notifier).state =
        normalizeOpportunityGroup(opportunities);

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
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Seleccione contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: DropdownButton<Opportunity>(
                isExpanded: true,
                value: seleccion,
                underline: Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                items: contactos
                    .map(
                      (o) => DropdownMenuItem<Opportunity>(
                        value: o,
                        child: Text(
                          (o.oprtNombreContacto ?? '').isNotEmpty
                              ? o.oprtNombreContacto!
                              : (o.contactId ?? ''),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
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
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(seleccion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Continuar'),
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
    context.push('/text').then((value) async {
      if (value == true && mounted) {
        await _refreshOpportunitiesList();
        if (mounted) setState(() {});
      }
    });
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
