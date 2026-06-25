import 'package:crm_app/features/shared/widgets/side_menu.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/kpi_stats_provider.dart';
import '../providers/vendedores_provider.dart';
import '../../domain/entities/kpi_stats.dart';

class KpiStatsScreen extends ConsumerStatefulWidget {
  const KpiStatsScreen({super.key});

  @override
  ConsumerState<KpiStatsScreen> createState() => _KpiStatsScreenState();
}

class _KpiStatsScreenState extends ConsumerState<KpiStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar vendedores al iniciar si es admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(vendedoresProvider.notifier).loadVendedores('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(kpiStatsProvider);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final user = ref.watch(authProvider).user;
    final isAdmin = user != null && user.type != 'V';
    final vendedoresState = isAdmin ? ref.watch(vendedoresProvider) : null;

    // Si es admin y hay vendedores, seleccionar el primero automáticamente
    if (isAdmin &&
        vendedoresState != null &&
        vendedoresState.vendedores.isNotEmpty &&
        !vendedoresState.isLoading) {
      final firstVendedor = vendedoresState.vendedores.first;
      final currentSelected = statsState.selectedUserId;
      if (currentSelected == null || currentSelected.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(kpiStatsProvider.notifier)
              .setSelectedUserId(firstVendedor.code);
        });
      }
    }

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Objetivos',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: statsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isAdmin && vendedoresState != null)
                      _VendedorSelector(
                        vendedores: vendedoresState.vendedores,
                        isLoading: vendedoresState.isLoading,
                        selectedVendedorCode: statsState.selectedUserId ?? '',
                        onVendedorChanged: (vendedorCode) {
                          ref
                              .read(kpiStatsProvider.notifier)
                              .setSelectedUserId(vendedorCode);
                        },
                      ),
                    if (isAdmin) const SizedBox(height: 20),
                    _YearSelector(
                      year: statsState.year,
                      onChanged: (year) =>
                          ref.read(kpiStatsProvider.notifier).setYear(year),
                    ),
                    const SizedBox(height: 20),
                    _BarChart(stats: statsState.stats),
                    const SizedBox(height: 30),
                    _StatsTable(stats: statsState.stats),
                  ],
                ),
              ),
            ),
    );
  }
}

class _VendedorSelector extends StatefulWidget {
  final List<UserMaster> vendedores;
  final bool isLoading;
  final String selectedVendedorCode;
  final ValueChanged<String> onVendedorChanged;

  const _VendedorSelector({
    required this.vendedores,
    required this.isLoading,
    required this.selectedVendedorCode,
    required this.onVendedorChanged,
  });

  @override
  State<_VendedorSelector> createState() => _VendedorSelectorState();
}

class _VendedorSelectorState extends State<_VendedorSelector> {
  UserMaster? _getSelectedVendedor() {
    try {
      return widget.vendedores.firstWhere(
        (v) => v.code == widget.selectedVendedorCode,
      );
    } catch (e) {
      return widget.vendedores.isNotEmpty ? widget.vendedores.first : null;
    }
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController();
    // Crear una copia local de la lista de vendedores para el diálogo
    List<UserMaster> allVendedores = List.from(widget.vendedores);
    List<UserMaster> filteredList = List.from(allVendedores);

    final selected = await showDialog<UserMaster>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Función para verificar si un string es un correo
            bool isEmail(String str) {
              return str.contains('@');
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Título y campo de búsqueda
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Buscar vendedor...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        searchController.clear();
                                        setDialogState(() {
                                          filteredList =
                                              List.from(allVendedores);
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value.isEmpty) {
                                  filteredList = List.from(allVendedores);
                                } else {
                                  // Si el valor contiene "@", buscar por correo
                                  // Si no, buscar por nombre
                                  if (isEmail(value)) {
                                    filteredList = allVendedores
                                        .where((v) => (v.email ?? '')
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  } else {
                                    filteredList = allVendedores
                                        .where((v) => v.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  }
                                }
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Lista de vendedores (búsqueda local, no necesita indicador de carga)
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron vendedores',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final vendedor = filteredList[index];
                                final isSelected = vendedor.code ==
                                    widget.selectedVendedorCode;
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      vendedor.abbrt ??
                                          vendedor.name.split(' ')[0][0] +
                                              vendedor.name.split(' ')[1][0],
                                    ),
                                  ),
                                  title: Text(
                                    vendedor.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle:
                                      Text(vendedor.email ?? 'Sin correo'),
                                  trailing: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : null,
                                  selected: isSelected,
                                  onTap: () {
                                    Navigator.of(context).pop(vendedor);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      widget.onVendedorChanged(selected.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedVendedor = _getSelectedVendedor();

    return InkWell(
      onTap: () => _showSearchDialog(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Seleccionar Vendedor',
          prefixIcon: const Icon(Icons.person),
          suffixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedVendedor?.name ?? 'Seleccionar vendedor...',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedVendedor != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearSelector extends StatelessWidget {
  final int year;
  final ValueChanged<int> onChanged;

  const _YearSelector({required this.year, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => onChanged(year - 1),
        ),
        Text(
          '$year',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => onChanged(year + 1),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<KpiStats> stats;

  const _BarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < stats.length) {
                    return Text(stats[index].periNombreMesAbr,
                        style: const TextStyle(fontSize: 13));
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox();

                  String text = '';
                  if (value >= 1000) {
                    text = '${(value / 1000).toStringAsFixed(0)}K';
                  } else {
                    text = value.toStringAsFixed(0);
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: const TextStyle(fontSize: 13)),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: stats.asMap().entries.map((entry) {
            int index = entry.key;
            KpiStats stat = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: stat.totalRegistro,
                  color: Colors.lightBlue,
                  width: 20, // Increased width since it's only one bar
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var stat in stats) {
      if (stat.totalRegistro > max) max = stat.totalRegistro;
      if (stat.objrCantidad > max) max = stat.objrCantidad;
    }
    return (max * 1.1).ceilToDouble();
  }
}

class _StatsTable extends StatelessWidget {
  final List<KpiStats> stats;

  const _StatsTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.black12),
          children: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('MES',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('VENTAS',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('OBJETIVO',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text('% AVANCE',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                )),
          ],
        ),
        ...stats.map((stat) {
          final color = _getAvanceColor(stat.avance);
          return TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(stat.periNombreMesAbr)),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    stat.totalRegistro.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    stat.objrCantidad.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  )),
              Container(
                color: stat.totalRegistro == 0 ? null : color,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  stat.totalRegistro == 0
                      ? ''
                      : '${stat.avance.toStringAsFixed(2)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        }),
        _buildTotalRow(),
      ],
    );
  }

  TableRow _buildTotalRow() {
    double totalVentas = stats.fold(0, (sum, item) => sum + item.totalRegistro);
    double totalObjetivo =
        stats.fold(0, (sum, item) => sum + item.objrCantidad);
    double totalAvance =
        totalObjetivo > 0 ? (totalVentas / totalObjetivo) * 100 : 0;

    return TableRow(
      decoration: const BoxDecoration(color: Colors.black12),
      children: [
        const Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              totalVentas.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              totalObjetivo.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            )),
        Container(
          color: _getAvanceColor(totalAvance),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${totalAvance.toStringAsFixed(2)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getAvanceColor(double avance) {
    if (avance <= 60) return Colors.red.shade400;
    if (avance <= 85) return Colors.yellow.shade400;
    return Colors.green.shade400;
  }
}
