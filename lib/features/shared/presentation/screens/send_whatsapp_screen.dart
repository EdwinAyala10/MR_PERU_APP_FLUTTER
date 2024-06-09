import 'dart:io';

import '../providers/send_whatsapp_provider.dart';
import '../../widgets/floating_action_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SendWhatsappScreen extends ConsumerWidget {
  const SendWhatsappScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(sendWhatsappProvider);

    final isViewText = ref.watch(sendWhatsappProvider).isViewText;

    /*if (isViewText) {
      context.push('/text');
    }*/

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Whatsapp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButtonCustom(
          callOnPressed: () async {

            ref
            .read(sendWhatsappProvider.notifier)
            .sendActivityMessage();

            //context.push('/send_whatsapp');
            context.pop();

            String phone = agregarPrefijoPeru(params.phone ?? '');
            String message = params.message ?? '';

            await whatsapp(phone, message);

            /*if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
              await launchUrl(Uri.parse(whatsappUrl));
            } else {
              throw 'Could not launch $whatsappUrl';
            }*/
            /*FlutterOpenWhatsapp.sendSingleMessage(
                agregarPrefijoPeru(params.phone ?? ''), params.message);*/
          },
          iconData: Icons.send),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              label: 'Código de País:',
              text: 'Perú (+51)',
            ),
            ContainerCustom(
              label: 'Número de télefono:',
              text: limpiarNumero(params.phone ?? ''),
            ),
            ContainerCustom(
              label: 'Mensaje:',
              text: params.message ?? '',
              icon: Icons.arrow_forward_ios_rounded,
              callbackIcon: () {
                context.push('/text');
              },
            ),
          ],
        ),
      ),
    );
  }
}

String limpiarNumero(String numero) {
  // Verificar si el número comienza con "+51" o "51"
  if (numero.startsWith('+51')) {
    // Eliminar "+51" del número
    return numero.substring(3);
  } else if (numero.startsWith('51')) {
    // Eliminar "51" del número
    return numero.substring(2);
  } else {
    // Si no comienza con ninguno de esos prefijos, devolver el número sin cambios
    return numero;
  }
}

whatsapp(String contact, String text) async {
  String androidUrl = "whatsapp://send?phone=$contact&text=$text";
  String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";

  String webUrl = 'https://api.whatsapp.com/send/?phone=$contact&text=hi';

  try {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(iosUrl))) {
        await launchUrl(Uri.parse(iosUrl));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(androidUrl))) {
        await launchUrl(Uri.parse(androidUrl));
      }
    }
  } catch (e) {
    await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
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
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      text,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 20, // Tamaño del icono
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
