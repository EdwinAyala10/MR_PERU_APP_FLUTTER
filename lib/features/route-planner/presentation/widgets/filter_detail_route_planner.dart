import 'package:flutter/material.dart';

class FilterDetailRoutePlanner extends StatelessWidget {
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
                      'Muestra sólo en seguimiento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                /*TextButton(
                  onPressed: () {
                    // Acción para aplicar filtros
                    Navigator.pop(context);
                  },
                  child: const Text('Hecho'),
                ),*/
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemBuilder: ( context, index) {
                final options = [
                  FilterOption(title: 'Sí'),
                  FilterOption(title: 'No'),
                  FilterOption(title: 'Todos'),
                  
                ];

                return options[index];
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption extends StatelessWidget {
  final String title;

  FilterOption({required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
         Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16.0)),
            
          ],
        ),
      ),
    );
  }
}
