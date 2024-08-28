import 'package:crm_app/features/activities/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/messages_item.dart';
import '../widgets/messages_form.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String senderName;

  const ChatScreen(this.senderName, {super.key});

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

  void _sendMessage(String messageContent) {
    ref.read(chatProvider).sendMessage(messageContent);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _scrollController.animateTo(
          -1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider).connectToServer();
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(),
          Expanded(
            child: ListView.builder(
              reverse: false,
              controller: _scrollController,
              itemCount: messagesProvider.messages.length,
              itemBuilder: (ctx, index) => MessagesItem(
                messagesProvider.messages[index],
                messagesProvider.messages[index].isUserMessage(
                  widget.senderName,
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
}
