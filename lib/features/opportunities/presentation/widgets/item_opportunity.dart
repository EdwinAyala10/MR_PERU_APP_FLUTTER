import 'dart:developer';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/activities/presentation/providers/providers.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:crm_app/features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import 'package:crm_app/features/shared/presentation/providers/send_whatsapp_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/domain.dart';
import 'package:flutter/material.dart';

class ItemOpportunity extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  final Function()? callbackOnTap;

  const ItemOpportunity(
      {super.key, required this.opportunity, required this.callbackOnTap});

  @override
  ConsumerState<ItemOpportunity> createState() => _ItemOpportunityState();
}

class _ItemOpportunityState extends ConsumerState<ItemOpportunity> {
  bool _microsoftSynced = false;

  Future<void> _loadMicrosoftSyncState() async {
    final synced = await KeyValueStorageServiceImpl().getValue<bool>('microsoft_synced');
    if (!mounted) return;
    setState(() {
      _microsoftSynced = synced == true;
    });
  }

  String _resolveEmailPreview() {
    // Prioridad: subject > emlsAsunto > actiComentario
    final subject = (widget.opportunity.subject ?? '').trim();
    if (subject.isNotEmpty) return subject;
    
    final emlsAsunto = (widget.opportunity.emlsAsunto ?? '').trim();
    if (emlsAsunto.isNotEmpty) return emlsAsunto;
    
    final comentario = (widget.opportunity.actiComentario ?? '').trim();
    if (comentario.isNotEmpty) return comentario;
    
    return 'Sin asunto';
  }

  ({Color? background, Color? border})? _staleColors() {
    final hasActivity = (widget.opportunity.actiIdTipoGestion ?? '').isNotEmpty &&
        (widget.opportunity.actiFechaRegistro ?? '').isNotEmpty;

    // Sin actividad: Amarillo suave con marco
    if (!hasActivity) {
      return (
        background: const Color(0xFFFFFDE7), // Amarillo muy suave interior
        border: const Color(0xFFFFEB3B), // Amarillo moderado marco
      );
    }

    final lastActivityDate = DateTime.tryParse(widget.opportunity.actiFechaRegistro!);
    if (lastActivityDate == null) return null;

    final daysWithoutActivity = DateTime.now().difference(lastActivityDate).inDays;
    
    // Más de 15 días: Rojo suave con marco (crítico)
    if (daysWithoutActivity > 15) {
      return (
        background: const Color(0xFFFFEBEE), // Rojo muy suave interior
        border: const Color(0xFFEF5350), // Rojo moderado marco
      );
    }
    
    // Más de 7 días: Naranja suave con marco (atención)
    if (daysWithoutActivity > 7) {
      return (
        background: const Color(0xFFFFF3E0), // Naranja muy suave interior
        border: const Color(0xFFFF9800), // Naranja moderado marco
      );
    }
    
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadMicrosoftSyncState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(contactProvider(widget.opportunity.contactId ?? '').notifier)
            .loadContact(widget.opportunity.contactId ?? '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactState =
        ref.watch(contactProvider(widget.opportunity.contactId ?? ''));
    final staleColors = _staleColors();

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: staleColors != null
              ? BoxDecoration(
                  color: staleColors.background,
                  border: Border.all(
                    color: staleColors.border!,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          title: Text(
            widget.opportunity.razon ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.opportunity.oprtNombreContacto ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              ),
              Text(
                widget.opportunity.oprtNombre == ''
                    ? '-'
                    : widget.opportunity.oprtNombre,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              Text(widget.opportunity.oprtNobbreEstadoOportunidad ?? ''),
              if (widget.opportunity.localDistrito != '')
                Text(widget.opportunity.localDistrito ?? ''),
              const SizedBox(height: 4),
              if (widget.opportunity.actiIdTipoGestion != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 1.0),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      border: Border.all(
                          color: Color.fromARGB(255, 218, 218, 218),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 2))
                      ]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ult. act.: ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 96, 95, 95),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      IconsActivity(
                          type: widget.opportunity.actiIdTipoGestion!,
                          size: 19),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        widget.opportunity.actiNombreTipoGestion ?? '',
                        style: const TextStyle(
                            color: Color.fromRGBO(130, 130, 130, 1),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 4,
              ),
              if (widget.opportunity.actiIdTipoGestion == '07' || (widget.opportunity.actiComentario ?? '').isNotEmpty)
                Row(
                  children: [
                    Icon(
                      widget.opportunity.actiIdTipoGestion == '07'
                        ? Icons.subject 
                        : Icons.mode_comment, 
                      size: 14
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                            widget.opportunity.actiIdTipoGestion == '07'
                                ? _resolveEmailPreview()
                                : (widget.opportunity.actiComentario ?? ''),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 3,
              ),
              if (widget.opportunity.actiFechaRegistro != "")
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Text(widget.opportunity.actiFechaRegistro ?? '',
                            overflow: TextOverflow.ellipsis)),
                  ],
                )
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.opportunity.oprtProbabilidad ?? ''}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '${widget.opportunity.oprtValor == '.00' ? '0.00' : widget.opportunity.oprtValor}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                widget.opportunity.nombreUsuarioResponsable ?? '',
                style: const TextStyle(
                    color: Colors.blue,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w800,
                    fontSize: 11),
              )
            ],
          ),
          leading: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.work_rounded,
                color: secondaryColor,
                size: 30,
              ),
            ],
          ),
            onTap: widget.callbackOnTap,
          ),
        ),
        Visibility(
          visible: contactState.contact == null ? false : true,
          child: Positioned(
            bottom: 1,
            right: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(selectOpportunity.notifier).state = null;
                    log("Estoy entrandoo aqui CELL");
                    ref.read(selectOpportunity.notifier).state =
                        widget.opportunity;
                    final contact = contactState.contact;
                    if (contact == null) {
                      return;
                    }
                    ref.read(selectOpportunity.notifier).state =
                        widget.opportunity;
                    context
                        .push(
                      '/activity_post_call/${contact?.id}/${agregarPrefijoPeru(
                        contact?.contactoTelefonoc ?? '',
                      )}',
                    )
                        .then((v) {
                      ref.read(selectOpportunity.notifier).state = null;
                    });
                  },
                  color: Colors.blueAccent,
                  icon: const Icon(
                    Icons.call,
                    size: 30,
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25),
                  ),
                  onTap: () {
                    log("Estoy entrandoo aqui whatsapp");

                    final contact = contactState.contact;
                    if (contact == null) {
                      return;
                    }
                    ref.read(sendWhatsappProvider.notifier).initialSend(
                          contact,
                          agregarPrefijoPeru(contact?.contactoTelefonoc ?? ''),
                          opportunity: widget.opportunity,
                        );
                    context.push('/text');
                  },
                  child: Image.asset(
                    'assets/images/icon_whatsapp.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  onTap: () async {
                    final contact = contactState.contact;
                    if (contact == null || (contact.contactoEmail ?? '').isEmpty) {
                      return;
                    }

                    await KeyValueStorageServiceImpl().setKeyValue<String>(
                      'email_return_route',
                      '/opportunities',
                    );
                    await KeyValueStorageServiceImpl().setKeyValue<String>(
                      'email_opportunity_id',
                      widget.opportunity.id,
                    );

                    context.push('/email_compose/${contact.id}');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A8DD), // Color celeste siempre activo
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.email, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
