import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/kpis/domain/domain.dart';
import 'package:crm_app/features/kpis/presentation/providers/kpis_by_asesor_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class KpisListScreen extends ConsumerWidget {
  static const String name = '/kpis-list';

  const KpisListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisState = ref.watch(kpisByAsesorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Objetivos',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: kpisState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _KpisListView(kpis: kpisState.kpis),
    );
  }
}

class _KpisListView extends StatelessWidget {
  final List<KpisByAsesor> kpis;

  const _KpisListView({required this.kpis});

  @override
  Widget build(BuildContext context) {
    // Filtrar asesores: quitar los que tienen codigo null o vacio, y los que no tienen objetivos
    final kpisWithData = kpis
        .where((kpi) =>
            kpi.asesorCodigo.trim().isNotEmpty &&
            (kpi.semanal.isNotEmpty ||
            kpi.mensual.isNotEmpty ||
            kpi.anual.isNotEmpty))
        .toList();

    if (kpisWithData.isEmpty) {
      return const Center(
        child: Text(
          'No hay objetivos disponibles',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Iterar sobre cada asesor
          for (var asesor in kpisWithData) ...[
            _AsesorObjectivesContainer(asesor: asesor),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AsesorObjectivesContainer extends StatelessWidget {
  final KpisByAsesor asesor;

  const _AsesorObjectivesContainer({required this.asesor});

  @override
  Widget build(BuildContext context) {
    final semanalKpis = asesor.semanal.toList();
    final mensualKpis = asesor.mensual.toList();
    final anualKpis = asesor.anual.toList();

    TextStyle periodicidadTitleTextStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.black,
    );

    // Determinar cuál es la primera periodicidad con datos para mostrar el código del asesor
    final bool showCodeInSemanal = semanalKpis.isNotEmpty;
    final bool showCodeInMensual = !showCodeInSemanal && mensualKpis.isNotEmpty;
    final bool showCodeInAnual = !showCodeInSemanal && !showCodeInMensual && anualKpis.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Objetivos Semanales
          if (semanalKpis.isNotEmpty) ...[
            DefaultTextStyle(
              style: periodicidadTitleTextStyle,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: const Text("Semanal"),
                    ),
                  ),
                  if (showCodeInSemanal)
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: Text(asesor.asesorAbbrt),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildObjectivesList(semanalKpis),
            const SizedBox(height: 16),
          ],

          // Objetivos Mensuales
          if (mensualKpis.isNotEmpty) ...[
            DefaultTextStyle(
              style: periodicidadTitleTextStyle,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: const Text("Mensual"),
                    ),
                  ),
                  if (showCodeInMensual)
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: Text(asesor.asesorAbbrt),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildObjectivesList(mensualKpis),
            const SizedBox(height: 16),
          ],

          // Objetivos Anuales
          if (anualKpis.isNotEmpty) ...[
            DefaultTextStyle(
              style: periodicidadTitleTextStyle,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: const Text("Anual"),
                    ),
                  ),
                  if (showCodeInAnual)
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: Text(asesor.asesorAbbrt),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildObjectivesList(anualKpis),
          ],
        ],
      ),
    );
  }

  Widget _buildObjectivesList(List<Kpi> kpis) {
    return Column(
      children: [
        // Si hay 1 o 2 objetivos TOTALES, usar Row de 2 columnas
        if (kpis.length <= 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: i < kpis.length
                        ? Center(
                            child: progressKpi(
                              percentage: (kpis[i].porcentaje ?? 0).toDouble(),
                              categoryId: kpis[i].objrIdCategoria,
                              title: kpis[i].objrNombre ?? '',
                              category: kpis[i].objrNombreCategoria ?? '',
                              subTitle: kpis[i].objrNombrePeriodicidad ?? '',
                              subSubTitle: kpis[i].objrNombreAsignacion ?? '',
                              advance: kpis[i].totalRegistro.toString(),
                              total: _convertTypeCategory(kpis[i]),
                            ),
                          )
                        : const SizedBox(), // Espacio vacío si solo hay 1
                  ),
              ],
            ),
          )
        // Si hay 3 o más, usar Rows de 3 columnas para las filas completas
        // y Row de 2 para la última fila si tiene 1 o 2 items
        else ...[
          // Calcular cuántas filas completas de 3 hay
          for (var rowIndex = 0; rowIndex < (kpis.length / 3).floor(); rowIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = rowIndex * 3; i < (rowIndex + 1) * 3; i++)
                    Expanded(
                      child: Center(
                        child: progressKpi(
                          percentage: (kpis[i].porcentaje ?? 0).toDouble(),
                          categoryId: kpis[i].objrIdCategoria,
                          title: kpis[i].objrNombre ?? '',
                          category: kpis[i].objrNombreCategoria ?? '',
                          subTitle: kpis[i].objrNombrePeriodicidad ?? '',
                          subSubTitle: kpis[i].objrNombreAsignacion ?? '',
                          advance: kpis[i].totalRegistro.toString(),
                          total: _convertTypeCategory(kpis[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Si sobran 1 o 2 items, usar Row de 2 columnas
          if (kpis.length % 3 != 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: ((kpis.length ~/ 3) * 3 + i) < kpis.length
                          ? Center(
                              child: progressKpi(
                                percentage: (kpis[(kpis.length ~/ 3) * 3 + i].porcentaje ?? 0).toDouble(),
                                categoryId: kpis[(kpis.length ~/ 3) * 3 + i].objrIdCategoria,
                                title: kpis[(kpis.length ~/ 3) * 3 + i].objrNombre ?? '',
                                category: kpis[(kpis.length ~/ 3) * 3 + i].objrNombreCategoria ?? '',
                                subTitle: kpis[(kpis.length ~/ 3) * 3 + i].objrNombrePeriodicidad ?? '',
                                subSubTitle: kpis[(kpis.length ~/ 3) * 3 + i].objrNombreAsignacion ?? '',
                                advance: kpis[(kpis.length ~/ 3) * 3 + i].totalRegistro.toString(),
                                total: _convertTypeCategory(kpis[(kpis.length ~/ 3) * 3 + i]),
                              ),
                            )
                          : const SizedBox(),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  String _convertTypeCategory(Kpi kpi) {
    String res = kpi.objrCantidad ?? '';
    
    // Solo agregar "K" si es categoría '05' (Oportunidades Ganadas)
    if (kpi.objrIdCategoria == '05') {
      try {
        final double value = double.parse(res);
        if (value % 1 == 0) {
          res = '${value.toInt()}K';
        } else {
          res = '${value.toStringAsFixed(1)}K';
        }
      } catch (e) {
        res = '0K';
      }
    } else {
      // Para otras categorías, solo mostrar el número sin "K"
      try {
        res = (double.parse(res).toInt()).toString();
      } catch (e) {
        res = '0';
      }
    }
    
    return res;
  }
}

class progressKpi extends StatelessWidget {
  double percentage;
  String categoryId;
  String title;
  String category;
  String subTitle;
  String subSubTitle;
  String advance;
  String total;

  progressKpi({
    super.key,
    required this.percentage,
    required this.categoryId,
    required this.title,
    required this.category,
    required this.subTitle,
    required this.subSubTitle,
    required this.advance,
    required this.total,
  });

  Color isColorIndicator(double porc) {
    Color returnColors = Colors.blue;

    if (porc >= 0 && porc <= 33) {
      returnColors = Colors.red;
    }

    if (porc >= 34 && porc <= 66) {
      returnColors = Colors.yellow;
    }

    if (porc >= 67 && porc <= 100) {
      returnColors = Colors.green;
    }

    return returnColors;
  }

  Color get indicatorColor {
    if (categoryId == '08') {
      // Para oportunidad sin seguimiento, el color depende del TOTAL_REGISTRO
      final totalRegistro = int.tryParse(advance) ?? 0;
      
      if (totalRegistro == 0) return Colors.grey;
      if (totalRegistro <= 2) return Colors.amber;
      return Colors.red;
    }

    return isColorIndicator(percentage);
  }

  double get indicatorValue {
    if (categoryId == '08') return 1.0;

    // Normalizar porcentaje si viene en formato incorrecto
    final normalizedPercentage = percentage > 1000 
        ? (percentage / 10000) 
        : (percentage / 100);
    
    return normalizedPercentage.clamp(0.0, 1.0);
  }

  bool get _showGoalTotal => categoryId != '08';

  String get displayValue {
    // Formatear TOTAL_REGISTRO a formato K si es >= 1000
    try {
      final int totalRegistro = int.parse(advance);
      if (totalRegistro >= 1000) {
        final double thousands = totalRegistro / 1000;
        if (thousands % 1 == 0) {
          return '${thousands.toInt()}K';
        } else {
          return '${thousands.toStringAsFixed(1)}K';
        }
      }
      return advance;
    } catch (e) {
      return advance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black45,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 10,
        ),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: 86,
              height: 86,
              child: CircularProgressIndicator(
                strokeWidth: 7,
                value: indicatorValue,
                valueColor: AlwaysStoppedAnimation<Color>(
                    indicatorColor), // Color cuando está marcado
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_showGoalTotal) ...[
                  const SizedBox(height: 1),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.black38,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          subTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        Text(
          subSubTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
