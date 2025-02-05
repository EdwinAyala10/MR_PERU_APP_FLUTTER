import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/infrastructure/mapers/create_document_response.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_provider.dart';
import 'package:crm_app/features/documents/presentation/providers/send_enlace_provider.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EnlaceScreen extends ConsumerWidget {
  const EnlaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final params = ref.watch(sendEnlaceProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guardar Enlace',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          /*leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              
              //Navigator.pop(context);

              context.pushReplacement('/documents');

              //context.pop();
          
            },
          ),*/
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
          callOnPressed: () async {
            //context.replace('/send_whatsapp');
            showLoadingMessage(context);

            ref.read(sendEnlaceProvider.notifier).sendEnlace().then((CreateDocumentResponse value) {
              if (value.message != '') {
                showSnackbar(context, value.message);
                if (value.response) {
                  ref.read(documentsProvider.notifier).loadNextPage();
                  //Navigator.pop(context);
                  context.pop();
                }
              }
              Navigator.pop(context);

            });

            //context.replace('/send_whatsapp');
            //context.pop();
            //Navigator.pop(context);
          }, 
          iconData: Icons.save
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: params.message,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese su enlace aquí',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey, // Cambia este color al que desees
                    ),
                  ),
                  onChanged: (String value) {
                     ref.watch(sendEnlaceProvider.notifier).onChangeMessage(value);
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
