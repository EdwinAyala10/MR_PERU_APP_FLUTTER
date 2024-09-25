import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/contacts/presentation/providers/providers.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_){
        ref.read(contactProvider(widget.opportunity.contactId ?? '').notifier).loadContact(widget.opportunity.contactId ?? '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactState =
        ref.watch(contactProvider(widget.opportunity.contactId ?? ''));

    return Stack(
      children: [
        ListTile(
          title: Text(
            widget.opportunity.razon ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.opportunity.oprtNombreContacto ?? '',
                style: const TextStyle(fontWeight: FontWeight.w400),
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
                        'Ultima actividad: ',
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
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.opportunity.actiComentario != "")
                Row(
                children: [
                  const Icon(Icons.mode_comment, size: 14),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 160,
                    child: Text(widget.opportunity.actiComentario ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                        ),
                      overflow: TextOverflow.ellipsis),
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
          leading: const Icon(
            Icons.work_rounded,
            color: secondaryColor,
            size: 40,
          ),
          onTap: widget.callbackOnTap,
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
                    final contact = contactState.contact;
                    if (contact == null) {
                      return;
                    }
                    context.push(
                        '/activity_post_call/${contact?.id}/${agregarPrefijoPeru(contact?.contactoTelefonoc ?? '')}');
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
                    final contact = contactState.contact;
                    if (contact == null) {
                      return;
                    }
                    ref.read(sendWhatsappProvider.notifier).initialSend(contact,
                        agregarPrefijoPeru(contact?.contactoTelefonoc ?? ''));
                    context.push('/text');
                  },
                  child: Image.asset(
                    'assets/images/icon_whatsapp.png',
                    width: 30,
                    height: 30,
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
