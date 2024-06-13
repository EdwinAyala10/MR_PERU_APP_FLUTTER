import 'dart:async';

import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';

import '../../domain/entities/send_indicators_response.dart';
import '../providers/indicators_provider.dart';
import '../../../users/domain/domain.dart';
import '../../../users/presentation/delegates/search_user_delegate.dart';
import '../../../users/presentation/search/search_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/shared.dart';
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
        body: const _ViewIndicators());
  }
}

class _ViewIndicators extends ConsumerStatefulWidget {
  const _ViewIndicators({super.key});

  @override
  _ViewIndicatorsState createState() => _ViewIndicatorsState();
}

class _ViewIndicatorsState extends ConsumerState {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.watch(indicatorsProvider.notifier).resetForm();
    });

  }

  @override
  Widget build(BuildContext context) {
    final indicatorsState = ref.watch(indicatorsProvider);

    return Column(
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
                    onTap: () => _selectDate(context, ref, 'ini'),
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
                                indicatorsState.dateInitial ?? DateTime.now()),
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
                    onTap: () => _selectDate(context, ref, 'end'),
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
                                indicatorsState.dateEnd ?? DateTime.now()),
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
                  'Usuarios',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        indicatorsState.arrayresponsables!.isNotEmpty
                            ? Wrap(
                                spacing: 6.0,
                                children: indicatorsState.arrayresponsables !=
                                        null
                                    ? List<Widget>.from(indicatorsState
                                        .arrayresponsables!
                                        .map((item) => Chip(
                                              label: Text(
                                                  item.userreportName ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              onDeleted: () {
                                                ref
                                                    .read(indicatorsProvider
                                                        .notifier)
                                                    .onDeleteUserChanged(item);
                                              },
                                            )))
                                    : [],
                              )
                            : const Text('Seleccione usuario(s)',
                                style: TextStyle(color: Colors.black45)),
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
                      backgroundColor: indicatorsState.isLoading ? secondaryColor : primaryColor, // Fondo de color naranja
                    ),
                    onPressed: indicatorsState.isLoading ? null : () {
                      ref.read(indicatorsProvider.notifier)
                          .onFormSubmit()
                          .then((SendIndicatorsResponse value) {
                            print(value.message);
                        //if ( !value.response ) return;
                        if (value.message != '') {
                          if (value.response) {
                            showSnackbar(context, value.message);
                            //Timer(const Duration(seconds: 3), () {
                            //});
                          }
                        }
                      });
                    },
                    child: const Text('Enviar informe',
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, WidgetRef ref, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    print(picked);

    //if (picked != null && picked != selectedDate) {
    if (picked != null) {
      if (type == 'ini') {
        ref.read(indicatorsProvider.notifier).onDateInitialChanged(picked);
      }
      if (type == 'end') {
        ref.read(indicatorsProvider.notifier).onDateEndChanged(picked);
      }
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

      ref.read(indicatorsProvider.notifier).onUsersChanged(user);
    });
  }
}
