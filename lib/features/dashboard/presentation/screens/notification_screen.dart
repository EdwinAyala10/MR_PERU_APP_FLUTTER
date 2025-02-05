import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/dashboard/domain/entities/notifying.dart';
import 'package:crm_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:crm_app/features/dashboard/presentation/providers/home_notificaciones_provider.dart';
import 'package:crm_app/features/shared/presentation/providers/notifications_provider.dart';
import 'package:crm_app/features/users/presentation/providers/users_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NofiticationScreen extends ConsumerWidget {
  static const String name = "/NofiticationScreen";
  const NofiticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listProviderNotify = ref.watch(listNotifyProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notificaciones'),
      ),
      body: Column(
        children: [
          listProviderNotify.isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: NotificationListener(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels + 400 ==
                          scrollInfo.metrics.maxScrollExtent) {
                        ref
                            .read(listNotifyProvider.notifier)
                            .listAllNotification();
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      notificationPredicate: defaultScrollNotificationPredicate,
                      onRefresh: () async {
                        ref
                            .read(listNotifyProvider.notifier)
                            .listAllNotification();
                      },
                      // key: refreshIndicatorKey,
                      child: ListView.separated(
                        itemCount:
                            ref.read(listNotifyProvider).activity?.length ?? 0,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          height: 0,
                        ),
                        itemBuilder: (context, index) {
                          final model =
                              listProviderNotify.activity?[index]; //     });
                          return Container(
                            color: model?.accmLeido == '0'
                                ? Colors.grey.shade200
                                : Colors.white,
                            child: ListTile(
                              title: Text(
                                  '${model?.userreportName ?? ''} te ha etiquetado:'),
                              onTap: () {
                                ref
                                    .read(listNotifyProvider.notifier)
                                    .readNotification(notifying: model);
                                ref.read(selectedNotifier.notifier).state =
                                    model?.accmIdActividad ?? '';

                                context
                                    .push(
                                  '/activity_detail/${model?.accmIdActividad}',
                                )
                                    .then((value) {
                                  ref
                                      .read(listNotifyProvider.notifier)
                                      .listAllNotification();
                                  ref
                                      .read(listNotifyProvider.notifier)
                                      .readCounterNotification();
                                });
                              },
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model?.accmComentario ?? '',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  Text(
                                    model?.accmTiempoGestion ?? '',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              leading: CircleAvatar(
                                child: Text(model?.userreportAbbrt ?? ''),
                              ),
                              // trailing: Column(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     Text(
                              //       model?.accmTiempoGestion ?? '',
                              //       style: const TextStyle(
                              //           color: Colors.grey, fontSize: 13),
                              //     ),
                              //   ],
                              // ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
