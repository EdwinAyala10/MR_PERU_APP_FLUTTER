import 'package:crm_app/features/activities/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/messages_item.dart';
import '../widgets/messages_form.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String userID;

  const ChatScreen(this.userID, {super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ConsumerChatScreenState();
}

class _ConsumerChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  // bool _isTyping = false;
  // bool _shouldScroll = false; // Bandera para controlar el scroll automático
  // String? _userNameTyping;

  get curve => null;

  void _onTyping() {}

  void _onStopTyping() {}

  void _sendMessage(String messageContent) async {
    ref.read(chatProvider).sendMessage(
          messageContent,
          ref.read(selectedUsersMarkedProvider) ?? [],
        );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await Future.delayed(const Duration(milliseconds: 200));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.bounceInOut,
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    ref.read(chatProvider.notifier).listUsersComentActivity();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(chatProvider.notifier).messages.clear();
      ref.read(chatProvider).listAllComents();
      ref.read(chatProvider).connectToServer();
      ref.read(chatProvider.notifier).listUsersComentActivity();

      await Future.delayed(
        const Duration(milliseconds: 500),
      );
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.bounceInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesProvider = ref.watch(chatProvider);
    final counter = ref.watch(chatProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                const Text('Participantes'),
                const Expanded(child: SizedBox()),
                MaterialButton(
                  elevation: 0,
                  color: Colors.blueAccent.shade100.withOpacity(0.5),
                  onPressed: () {
                    ref.read(chatProvider.notifier).listUsersComentActivity();
                    showModalParcipantes();
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_4_outlined,
                        color: Colors.blueAccent,
                      ),
                      Text(
                        '  ${counter.listUsersInChat.length} Usuarios',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Visibility(
                    visible: false,
                    child: Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0),
              reverse: false,
              controller: _scrollController,
              itemCount: messagesProvider.messages.length,
              itemBuilder: (ctx, index) => SizedBox(
                // color: Colors.red,
                child: MessagesItem(
                  messagesProvider.messages[index],
                  messagesProvider.messages[index].isUserMessage(
                    widget.userID,
                  ),
                ),
              ),
            ),
          ),
          // Visibility(
          //   visible: _isTyping,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       children: <Widget>[
          //         Text(
          //           '$_userNameTyping is typing',
          //           // style: Theme.of(context).textTheme.title.copyWith(
          //           //       color: Colors.black54,
          //           //       fontWeight: FontWeight.w400,
          //           //       fontSize: 14,
          //           //     ),
          //         ),
          //         // Lottie.asset(
          //         //   'assets/animations/chat-typing-indicator.json',
          //         //   width: 40,
          //         //   height: 40,
          //         //   alignment: Alignment.bottomLeft,
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),
          MessageForm(
            onSendMessage: _sendMessage,
            onTyping: _onTyping,
            onStopTyping: _onStopTyping,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future<void> showModalParcipantes() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final size = MediaQuery.of(context).size;
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final chatProv = ref.watch(chatProvider);
                return SizedBox(
                  height: size.height * 0.6,
                  width: size.width * 0.90,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'PARTICIPANTES',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      chatProv.listUsersInChat.isEmpty
                          ? const Expanded(
                              child: Center(
                                child: Text('Aun no hay participantes'),
                              ),
                            )
                          : Expanded(
                              child: NotificationListener(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels + 400 ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                    ref
                                        .read(chatProvider.notifier)
                                        .listUsersComentActivity();
                                  }
                                  return false;
                                },
                                child: RefreshIndicator(
                                  notificationPredicate:
                                      defaultScrollNotificationPredicate,
                                  onRefresh: () async {
                                    ref
                                        .read(chatProvider.notifier)
                                        .listUsersComentActivity();
                                  },
                                  // key: refreshIndicatorKey,
                                  child: ListView.separated(
                                    itemCount: chatProv.listUsersInChat.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(),
                                    itemBuilder: (context, index) {
                                      final model = chatProv
                                          .listUsersInChat[index]; //     });
                                      return ListTile(
                                        title: Text(model.userreportName ?? ''),
                                        subtitle: Text(
                                          model.userreportEmail ?? '',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                        ),
                                        leading: CircleAvatar(
                                          child:
                                              Text(model.userreportAbbrt ?? ''),
                                        ),
                                        // trailing: Column(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.end,
                                        //   children: [
                                        //     Text(
                                        //       model.userreportCodigo ?? '',
                                        //       style: const TextStyle(
                                        //           color: Colors.grey,
                                        //           fontSize: 13),
                                        //     ),
                                        //   ],
                                        // ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}
