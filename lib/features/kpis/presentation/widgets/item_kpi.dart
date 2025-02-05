
import 'package:crm_app/features/kpis/domain/entities/kpi.dart';
import 'package:crm_app/features/kpis/presentation/screens/kpi_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemKpi extends ConsumerWidget {
  const ItemKpi({
    Key? key,
    required this.data,
    required this.isFirst,
    required this.isLast,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  final Kpi data;
  final bool isFirst;
  final bool isLast;
  final int index;
  final Function() onTap;

  Widget _buildChild(BuildContext context, ReorderableItemState state, WidgetRef ref) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    Widget content = GestureDetector(
      onTap: () {
        print('HOla');
        onTap();
      },
      child: Container(
        decoration: decoration,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Opacity(
              // hide content for placeholder
              opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 14.0),
                          child: Row(
                            children: [
                              
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,
                                      value: ((data.porcentaje ?? 0) / 100).toDouble(),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isColorIndicator(data.porcentaje ?? 0),
                                      ), // Color cuando está marcado
                                      backgroundColor: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${data.porcentaje!.round()}%", // El porcentaje se multiplica por 100 para mostrarlo correctamente
                                    style: const TextStyle(
                                      fontSize: 13, // Tamaño del texto
                                      color: Colors.black, // Color del texto
                                      fontWeight: FontWeight.bold, // Negrita
                                    ),
                                  ),
                                ],
                              ),
      
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.objrNombre,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(data.objrNombreCategoria ?? '',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.black87
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: Text(data.objrNombrePeriodicidad ?? '',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.black54,
                                          fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: Text(data.objrNombreAsignacion ?? '',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.black54,
                                          fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: Text('${data.totalRegistro}/${convertTypeCategory(data)}',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.black54,
                                          fontSize: 13
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          for (var i = 0;
                                              i < 2 && i < data.usuariosAsignados!.length;
                                              i++)
                                            Text(
                                              data.usuariosAsignados![i].userreportName ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  
                                ],
                              ),
                            ],
                          ),
                        )
                    ),
                    ReorderableListener(
                      child: Container(
                        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                        color: const Color(0x08000000),
                        child: const Center(
                          child: Icon(Icons.reorder, color: Color(0xFF888888)),
                        ),
                      ),
                      /*canStart: () {
                        ref.read(routePlannerProvider.notifier).onLocalesTemp();
                        return true;
                      },*/
                    ),
                  ],
                ),
              ),
            )),
      ),
    );

    return content;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableItem(
        key: data.key!, //
        childBuilder: (BuildContext context, ReorderableItemState state) {
          return _buildChild(context, state, ref);
        });
  }

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
    
    print('PORCENTAJE: ${porc}');
    return returnColors; 
  }
}