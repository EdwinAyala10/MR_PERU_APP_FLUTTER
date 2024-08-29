import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/item_company.dart';
import 'package:crm_app/features/contacts/presentation/widgets/item_contact.dart';
import 'package:crm_app/features/kpis/presentation/providers/kpis_by_cat_provider.dart';
import 'package:crm_app/features/kpis/presentation/widgets/custom_switch.dart';
import 'package:crm_app/features/kpis/presentation/widgets/item_objetive_by_category.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/item_opportunity.dart';

import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:crm_app/features/kpis/domain/entities/kpi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpiDetailScreen extends ConsumerWidget {
  final String kpiId;

  const KpiDetailScreen({
    super.key,
    required this.kpiId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiState = ref.watch(kpiProvider(kpiId));
    final kpi = kpiState.kpi;
    final user = ref.watch(authProvider).user;
    final isAdmin = user!.isAdmin;
    final selectIndexView = ref.watch(selecIndexViewProvider);
    if (kpiState.isLoading) {
      return const FullScreenLoader();
    }
    if (kpi == null) {
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
                'No se encontro información de objetivo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de objetivo',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/kpi/${kpi.id}');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          resumedHeadData(context, ref),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CustomSwitch(
                        options: const ['Information', 'Performance'],
                        index: selectIndexView,
                        onChanged: (index) {
                          ref.read(selecIndexViewProvider.notifier).state =
                              index;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      selectIndexView == 1
                          ? Expanded(
                              child: SizedBox(
                                child: informationSection(kpi),
                              ),
                            )
                          : Expanded(
                              child: SizedBox(
                                child: perfomceSection(context, ref),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget resumedHeadData(BuildContext context, WidgetRef ref) {
    final kpi = ref.read(goalsModelProvider);
    if (kpi == null) {
      return Container();
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28),
      title: Text(
        kpi.objrNombreCategoria ?? '',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${kpi.totalRegistro}/${convertTypeCategory(kpi)}',
            style: const TextStyle(
                fontWeight: FontWeight.w400, color: Colors.black45),
          )
        ],
      ),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              value: ((kpi.porcentaje ?? 0) / 100).toDouble(),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ), // Color cuando está marcado
              backgroundColor: Colors.grey,
            ),
          ),
          Text(
            "${kpi.porcentaje!.round()}%", // El porcentaje se multiplica por 100 para mostrarlo correctamente
            style: const TextStyle(
              fontSize: 13, // Tamaño del texto
              color: Colors.black, // Color del texto
              fontWeight: FontWeight.bold, // Negrita
            ),
          ),
        ],
      ),
      // onTap: () {},
    );
  }

  Widget perfomceSection(BuildContext context, WidgetRef ref) {
    final response = ref.watch(kpisByCatNotifierProvider);

    if (response.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (response.items.isEmpty) {
      return const Center(
        child: Text('No se encontraron registros'),
      );
    }
    return RefreshIndicator(
      // notificationPredicate: defaultScrollNotificationPredicate,
      onRefresh: () async {
        ref.read(kpisByCatNotifierProvider.notifier).listKpiByCategory();
      },
      //key: _refreshIndicatorKey,
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: ListView.separated(
          itemCount: response.items.length, // widget.companies.length,
          //controller: widget.scrollController,
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (
            BuildContext context,
            int index,
          ) =>
              const Divider(),
          itemBuilder: (context, index) {
            final type =
                ref.read(kpisByCatNotifierProvider.notifier).kpiProviders;
            if (type?.objrIdCategoria == TypeCategory.chekIns) {
              return ItemActivity(
                activity: response.items[index],
                callbackOnTap: () {},
              );
            }
            if (type?.objrIdCategoria == TypeCategory.nuevaEmpresa) {
              return ItemCompany(
                company: response.items[index],
                index: index,
                callbackOnTap: () {},
              );
            }
            if (type?.objrIdCategoria == TypeCategory.nuevoContacto) {
              return ItemContact(
                contact: response.items[index],
                callbackOnTap: () {},
              );
            }
            if (type?.objrIdCategoria == TypeCategory.nuevaOportunidad) {
              return ItemOpportunity(
                opportunity: response.items[index],
                callbackOnTap: () {},
              );
            }
            if (type?.objrIdCategoria == TypeCategory.oportunidadesGanadas) {
              return ItemOpportunity(
                opportunity: response.items[index],
                callbackOnTap: () {},
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  SingleChildScrollView informationSection(Kpi kpi) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            ContainerCustom(
              label: 'Responsable',
              text: kpi.userreportNameResponsable ?? '',
            ),
            ContainerCustom(
              label: 'Asignación',
              text: kpi.objrNombreAsignacion ?? '',
            ),
            if (kpi.arrayuserasignacion != null &&
                kpi.arrayuserasignacion!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usuarios',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: kpi.arrayuserasignacion!.map(
                        (arr) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${arr.userreportName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 13, bottom: 10, top: 10),
              child: Text('DEFINICION DE OBJETIVO',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            ContainerCustom(
              label: 'Categoria',
              text: '${kpi.objrNombreCategoria}',
            ),
            ContainerCustom(
              label: 'Tipo',
              text: '${kpi.objrNombreTipo}',
            ),
            ContainerCustom(
              label: 'Nombre de objetivo',
              text: kpi.objrNombre,
            ),
            ContainerCustom(
              label: 'Periodicidad',
              text: kpi.objrNombrePeriodicidad ?? '',
            ),
            ContainerCustom(
              label: 'Objetivo Alcanzar',
              text: kpi.objrCantidad ?? '',
            ),
            if (kpi.objrIdPeriodicidad == '02' || kpi.objrValorDifMes == '1')
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Valor diferente cada mes',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Cabecera de la tabla
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  'Cantidad',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(),
                            // Listado de filas
                            Column(
                              children: kpi.peobIdPeriodicidad!.map((dato) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dato.periNombre ?? ''),
                                      Text(dato.peobCantidad.toString()),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            ContainerCustom(
              label: 'Comentario',
              text: kpi.objrObservaciones ?? '',
            ),
          ],
        ),
      ),
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

convertTypeCategory(Kpi kpi) {
  String res = kpi.objrCantidad ?? '';
  if (kpi.objrIdCategoria == '05') {
    res = ' ${res}K';
  } else {
    res = (double.parse(res).toInt()).toString();
  }
  return res;
}
