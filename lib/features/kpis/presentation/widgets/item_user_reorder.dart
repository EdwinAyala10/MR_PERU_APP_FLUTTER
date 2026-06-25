import 'package:crm_app/features/users/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemUserReorder extends ConsumerWidget {
  const ItemUserReorder({
    Key? key,
    required this.user,
    required this.isFirst,
    required this.isLast,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  final UserMaster user;
  final bool isFirst;
  final bool isLast;
  final int index;
  final Function() onTap;

  Widget _buildChild(
      BuildContext context, ReorderableItemState state, WidgetRef ref) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: BorderSide.none,
              bottom: !isLast && !placeholder
                  ? Divider.createBorderSide(context)
                  : BorderSide.none),
          color: placeholder ? null : Colors.white);
    }

    Widget content = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Opacity(
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
                          // Ícono de usuario
                          Center(
                            child: Icon(
                              Icons.perm_contact_calendar_rounded,
                              size: 36,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Información del usuario
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (user.email != null &&
                                    user.email!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    // Handle de arrastre
                    ReorderableListener(
                      child: Container(
                        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                        color: const Color(0x08000000),
                        child: Center(
                          child: Icon(Icons.reorder, color: Colors.grey[600]),
                        ),
                      ),
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
        key: ValueKey(index),
        childBuilder: (BuildContext context, ReorderableItemState state) {
          return _buildChild(context, state, ref);
        });
  }
}
