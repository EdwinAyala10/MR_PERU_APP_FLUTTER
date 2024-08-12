import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';

import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpiDetailScreen extends ConsumerWidget {
  final String kpiId;

  const KpiDetailScreen({super.key, 
    required this.kpiId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiState = ref.watch(kpiProvider(kpiId));

    final kpi = kpiState.kpi;

    final user = ref.watch(authProvider).user;

    final isAdmin = user!.isAdmin;

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
                ))
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de objetivo', style: TextStyle(
          fontWeight: FontWeight.w500
        ),),
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
      body: SingleChildScrollView(
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
                padding: const EdgeInsets.symmetric( horizontal: 10 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Usuarios', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          kpi.arrayuserasignacion!.map((arr) {
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
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 13, bottom: 10, top: 10),
                child: Text('DEFINICION DE OBJETIVO', style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16
                )),
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
                      child: Text('Valor diferente cada mes', style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                      ),),
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
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Cantidad',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Listado de filas
                              Column(
                                children: kpi.peobIdPeriodicidad!.map((dato) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
