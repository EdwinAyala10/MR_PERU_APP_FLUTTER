import 'package:crm_app/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/domain.dart';
import '../providers/contact_provider.dart';
import '../providers/providers.dart';
import '../../../shared/presentation/providers/send_whatsapp_provider.dart';
import '../../../shared/shared.dart';
import 'package:crm_app/features/shared/widgets/email_feedback_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crm_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';

class ContactDetailScreen extends ConsumerStatefulWidget {
  final String contactId;

  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  @override
  _ContactDetailScreenState createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen> {
  @override
  void initState() {
    super.initState();
    initializedServices();
  }

  @override
  initializedServices() async {
    await KeyValueStorageServiceImpl().setKeyValue('current_contact_id', widget.contactId);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref
          .read(contactProvider(widget.contactId).notifier)
          .loadContact(widget.contactId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactProvider(widget.contactId));
    if (contactState.isLoading) {
      return const Scaffold(
        body: FullScreenLoader(),
      );
    }

    return contactState.contact != null
        ? _ViewContactDetailScreen(contact: contactState.contact!)
        : Scaffold(
            appBar: AppBar(
              title: const Text('Contacto'),
            ),
            body: const Center(
              child: Text('No existe información del contacto.'),
            ),
          );
  }
}

class _ViewContactDetailScreen extends ConsumerStatefulWidget {
  final Contact contact;

  const _ViewContactDetailScreen({
    required this.contact,
  });

  @override
  ConsumerState<_ViewContactDetailScreen> createState() =>
      _ViewContactDetailScreenState();
}

class _ViewContactDetailScreenState extends ConsumerState<_ViewContactDetailScreen>
    {
  bool _microsoftSynced = false;

  @override
  void initState() {
    super.initState();
    _loadMicrosoftSyncState();
  }

  Future<void> _loadMicrosoftSyncState() async {
    final synced = await KeyValueStorageServiceImpl().getValue<bool>('microsoft_synced');
    final showMessage = await KeyValueStorageServiceImpl().getValue<bool>('show_sync_message');
    if (!mounted) return;
    setState(() {
      _microsoftSynced = synced == true;
    });

    if (showMessage == true) {
      await KeyValueStorageServiceImpl().setKeyValue<bool>('show_sync_message', false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        EmailFeedbackSnackbar.showSyncSuccess(context);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    //ref.read(contactProvider(contactId).notifier).loadContact();
    //final contactState = ref.watch(contactProvider(contactId));

    //print('CONTACT STATE ${contactId}');

    //final contact = contactState.contact;

    /*if (contactState.isLoading) {
      return const FullScreenLoader();
    }*/

    if (contact == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información del contacto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/contacts');
          },
        ),
        title: const Text('Detalles del contacto',
        style: TextStyle(
          fontWeight: FontWeight.w500
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/contact/${contact.id}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/avatar.svg',
                      height: 68.0,
                      width: 64.0,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      contact.contactoDesc,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'DATOS DE EMPRESA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerCustom(
                label: 'RUC:',
                text: contact.ruc ?? '',
              ),
              ContainerCustom(
                label: 'Empresa:',
                text: contact.razon ?? '',
              ),
              ContainerCustom(
                label: 'Local:',
                text: contact.contactoLocalNombre ?? '',
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerCustom(
                label: 'Cargo:',
                text: contact.contactoCargo,
              ),
              ContainerCustom(
                label: 'Celular:',
                text: contact.contactoTelefonoc,
                icon: Icons.call_sharp,
                callbackIcon: () {
                  context.push(
                      '/activity_post_call/${contact.id}/${agregarPrefijoPeru(contact.contactoTelefonoc)}');
                },
                icon2: Image.asset(
                  'assets/images/icon_whatsapp.png',
                  width: 26,
                  height: 26,
                ),
                callbackIcon2: () {
                  ref.read(sendWhatsappProvider.notifier).initialSend(
                      contact, agregarPrefijoPeru(contact.contactoTelefonoc));
                  context.push('/text');
                },
              ),
              ContainerCustom(
                label: 'Teléfono:',
                text: contact.contactoTelefonof ?? '',
                icon: Icons.call_sharp,
                callbackIcon: () {
                  context.push(
                      '/activity_post_call/${contact.id}/${agregarPrefijoPeru(contact.contactoTelefonof!)}');
                },
                icon2: Image.asset(
                  'assets/images/icon_whatsapp.png',
                  width: 26,
                  height: 26,
                ),
                callbackIcon2: () {
                  ref.read(sendWhatsappProvider.notifier).initialSend(
                      contact, agregarPrefijoPeru(contact.contactoTelefonof!));
                  context.push('/text');
                },
              ),
              ContainerCustom(
                label: 'Correo electrónico:',
                text: contact.contactoEmail ?? '',
                icon2: _InlineEmailButton(isConnected: _microsoftSynced),
                callbackIcon2: () {
                  if ((contact.contactoEmail ?? '').isEmpty) return;
                  if (_microsoftSynced) {
                    context.push('/email_compose/${contact.id}');
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (_) => EmailSyncDialog(
                      message: 'Para enviar correos electronicos a traves de Force MR, necesitas habilitar la sincronizacion para tu cuenta de correo electronico.',
                      onContinueWithoutConfig: () async {
                        await KeyValueStorageServiceImpl().setKeyValue<bool>('microsoft_synced', true);
                        if (!context.mounted) return;
                        context.push('/email_compose/${contact.id}');
                      },
                    ),
                  );
                },
              ),
              ContainerCustom(
                label: 'Comentarios:',
                text: contact.contactoNotas ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmailButton extends StatelessWidget {
  final bool isConnected;
  const _InlineEmailButton({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFF4FC3F7)
            : const Color.fromARGB(255, 155, 155, 155),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.email, color: Colors.white, size: 20),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  String label;
  String text;
  IconData? icon;
  Function()? callbackIcon;
  Widget? icon2;
  Function()? callbackIcon2;
  ContainerCustom(
      {super.key,
      required this.label,
      required this.text,
      this.icon,
      this.callbackIcon,
      this.icon2,
      this.callbackIcon2});

  @override
  Widget build(BuildContext context) {
    if (text == "") {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Expanded(child: SizedBox()),
                icon2 != null
                    ? IconButton(
                        icon: icon2!,
                        iconSize: 20, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon2,
                      )
                    : const SizedBox(),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 30, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

String agregarPrefijoPeru(String numero) {
  // Verificar si el número ya tiene el prefijo de país "+51"
  if (!numero.startsWith('+51')) {
    // Si no tiene el prefijo, agregarlo al principio
    return '+51$numero';
  }
  // Si ya tiene el prefijo, devolver el número sin cambios
  return numero;
}
