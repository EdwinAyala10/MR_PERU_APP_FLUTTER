import 'package:crm_app/features/route-planner/presentation/widgets/filter_detail_route_planner.dart';
import 'package:flutter/material.dart';

class FilterBottomRouterPlannerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double desiredHeight = screenHeight * 0.95; // 85% de la altura de la pantalla

    return Container(
      height: desiredHeight,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Filtros Empresas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Acción para aplicar filtros
                    Navigator.pop(context);
                  },
                  child: const Text('Hecho'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemBuilder: ( context, index) {
                final options = [
                  FilterOption(title: 'Muestra sólo en seguimiento', trailing: 'Todos'),
                  FilterOption(title: 'Actividad', trailing: 'Más de 30 días'),
                  FilterOption(title: 'Tipo', trailing: 'Posible Cliente'),
                  FilterOption(title: 'Estado', trailing: 'Prospecto'),
                  FilterOption(title: 'Calificación', trailing: '6 valores'),
                  FilterOption(title: 'Responsable', trailing: 'Richard Ramirez'),
                  FilterOption(title: 'Código postal', trailing: 'Selecciona'),
                  
                  FilterOption(title: 'RUC', trailing: 'Selecciona'),
                  FilterOption(title: 'RUBRO', trailing: 'Selecciona'),
                  FilterOption(title: 'Razón comercial', trailing: 'Selecciona'),
                ];

                return options[index];
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption extends StatelessWidget {
  final String title;
  final String trailing;

  FilterOption({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FilterDetailRoutePlanner(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16.0)),
            Row(
              children: [
                Text(trailing, style: const TextStyle(color: Colors.grey)),
                const SizedBox(
                  width: 10,
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color.fromARGB(255, 131, 131, 131),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
