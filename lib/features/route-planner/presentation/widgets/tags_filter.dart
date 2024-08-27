import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/route-planner/domain/domain.dart';
import 'package:crm_app/features/route-planner/presentation/providers/route_planner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagRowRoutePlanner extends ConsumerStatefulWidget {
  @override
  _TagRowState createState() => _TagRowState();
}

class _TagRowState extends ConsumerState<TagRowRoutePlanner> {
  bool showAllTags = false;

  @override
  Widget build(BuildContext context) {

    final List<FilterOption> listFiltersSuccess = ref.watch(routePlannerProvider).filtersSuccess;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listFiltersSuccess.length,
                    itemBuilder: (context, index) {
                      
                      var filter = listFiltersSuccess[index];

                      var label = '${filter.title} : ${filter.name}';

                      return TagItem(
                        label: label,
                        onDelete: () {
                          /*setState(() {
                            tags.removeAt(index);
                          });*/
                          ref.read(routePlannerProvider.notifier).onDeleteFilter(index);
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
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
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Total: ',
            style: TextStyle(color: Color.fromARGB(255, 62, 62, 62),
            fontWeight: FontWeight.w600),
          ),
          Text(
            '${listFiltersSuccess.length}',
            style: const TextStyle(color: Color.fromARGB(255, 62, 62, 62)),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              ref.read(routePlannerProvider.notifier).onDeleteAllFilter();
            },
            borderRadius: BorderRadius.circular(50.0),
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 18.0,
              height: 18.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 13.0,
              ),
            )
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style: const TextStyle(color: primaryColor),
          ),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }
}