import 'dart:async';

import 'package:crm_app/features/users/domain/domain.dart';
import 'package:crm_app/features/users/presentation/delegates/search_user_delegate.dart';
import 'package:crm_app/features/users/presentation/search/search_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crm_app/features/shared/shared.dart';
import 'package:intl/intl.dart';

class IndicatorsScreen extends ConsumerWidget {
  const IndicatorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Indicadores',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
        
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Text(
                    'Fecha Inicio',
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
                              /*DateFormat('dd-MM-yyyy').format(
                                  activityForm.actiFechaActividad ?? DateTime.now()),*/
                              DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Fecha Fin',
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
                              /*DateFormat('dd-MM-yyyy').format(
                                  activityForm.actiFechaActividad ?? DateTime.now()),*/
                              DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  const Text('Usuarios', style: TextStyle(
                    fontWeight: FontWeight.w500
                  ),),
                  Row(
                    children: [
                      const Expanded(
                          child: Column(
                        children: [
                          /*opportunityForm.arrayresponsables!.isNotEmpty
                              ? Wrap(
                                  spacing: 6.0,
                                  children: opportunityForm.arrayresponsables != null
                                      ? List<Widget>.from(opportunityForm
                                          .arrayresponsables!
                                          .map((item) => Chip(
                                                label: Text(item.userreportName ?? '',
                                                    style:
                                                        const TextStyle(fontSize: 12)),
                                                onDeleted: () {
                                                  ref
                                                      .read(opportunityFormProvider(
                                                              opportunity)
                                                          .notifier)
                                                      .onDeleteUserChanged(item);
                                                },
                                              )))
                                      : [],
                                )
                              : const Text('Seleccione usuario(s)',
                                  style: TextStyle(color: Colors.black45)),
                            */
                            Text('Seleccione usuario(s)',
                                  style: TextStyle(color: Colors.black45))

                        ],
                      )),
                      ElevatedButton(
                        onPressed: () {
                          _openSearchUsers(context, ref);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Fondo de color naranja
                      ),
                      onPressed: () {
                        // Acción a realizar cuando se presiona el botón
                      },
                      child: Text('Enviar informe', style: TextStyle(color: Colors.white)),
                    ),
                  )

                ],
              ),
            ),
          )
          ,
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
    print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      //ref.read(activityFormProvider(activity).notifier).onFechaChanged(picked);
    }
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

      /*ref
          .read(opportunityFormProvider(opportunity).notifier)
          .onUsuarioChanged(user);*/
    });
  }
}


