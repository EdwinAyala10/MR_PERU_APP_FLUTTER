import 'package:flutter/material.dart';

class TagRowRoutePlanner extends StatefulWidget {
  @override
  _TagRowState createState() => _TagRowState();
}

class _TagRowState extends State<TagRowRoutePlanner> {
  bool showAllTags = false;
  List<String> tags = [
    'Muestra sólo en seguimiento: Todos',
    'Actividad: Más de 30 días',
    'Tipo: Posible cliente',
    'Estado: Prospecto',
    'Calificación:  6 valores',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return TagItem(
                        label: tags[index],
                        onDelete: () {
                          setState(() {
                            tags.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !showAllTags,
                    child: AnimatedOpacity(
                      opacity: showAllTags ? 0.0 : 1.0,
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        width: 50.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white,
                            ],
                            stops: [0.0, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          TextButton(
            onPressed: () {
              setState(() {
                showAllTags = !showAllTags;
              });
            },
            child: Row(
              children: [
                Text('Total: 6', style: TextStyle(color: const Color.fromARGB(255, 62, 62, 62)),),
                SizedBox(
                  width: 10,
                ),
                Container(child: Icon(Icons.close, size: 20,))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TagItem extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  TagItem({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 4.0),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}