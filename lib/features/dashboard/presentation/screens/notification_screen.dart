import 'package:crm_app/features/dashboard/presentation/providers/home_notificaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                            const Divider(),
                        itemBuilder: (context, index) {
                          final model =
                              listProviderNotify.activity?[index]; //     });
                          return ListTile(
                            title: Text(model?.userreportName ?? ''),
                            subtitle: Text(
                              model?.accmComentario ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            leading: CircleAvatar(
                              child: Text(model?.userreportAbbrt ?? ''),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  model?.accmTiempoGestion ?? '',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
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
