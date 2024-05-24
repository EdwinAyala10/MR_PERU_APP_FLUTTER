import '../providers/send_whatsapp_provider.dart';
import '../../widgets/floating_action_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TextScreen extends ConsumerWidget {
  const TextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final params = ref.watch(sendWhatsappProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enviar Whatsapp',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Para Pepito',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.replace('/send_whatsapp');
              //context.pop();
            },
          ),
          /*actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // Acción al presionar el botón de guardar
              },
            ),
          ],*/
        ),
        floatingActionButton: FloatingActionButtonCustom(
          callOnPressed: () {
            context.replace('/send_whatsapp');
          }, 
          iconData: Icons.check_sharp
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: params.message,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese su texto aquí',
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) {
                     ref.watch(sendWhatsappProvider.notifier).onChangeMessage(value);
                  },
                  maxLines: null,
                  minLines: null,
                  expands: true,
                ),
              )
            ],
          ),
        ));
  }
}
