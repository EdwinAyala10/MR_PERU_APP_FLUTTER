import 'package:crm_app/features/activities/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class MessagesItem extends StatelessWidget {
  final MessageModel _message;

  final bool isUserMassage;

  const MessagesItem(this._message, this.isUserMassage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection:
                isUserMassage ? TextDirection.rtl : TextDirection.ltr,
            children: <Widget>[
              isUserMassage
                  ? const SizedBox()
                  : Card(
                      elevation: 10,
                      color: isUserMassage
                          ? Theme.of(context).primaryColor.withOpacity(.8)
                          : Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(isUserMassage ? 20 : 0),
                          bottomLeft: Radius.circular(isUserMassage ? 0 : 20),
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                        ),
                      ),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          _message.senderName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              Column(
                crossAxisAlignment: isUserMassage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  isUserMassage
                      ? const SizedBox()
                      : Container(
                          padding: isUserMassage
                              ? const EdgeInsets.only(right: 15)
                              : const EdgeInsets.only(left: 15),
                          child: FittedBox(
                            child: Text(
                              _message.senderName,
                              style: TextStyle(
                                color: Colors.black.withOpacity(.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 3,
                  ),
                  Align(
                    alignment: isUserMassage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: Card(
                        elevation: 10,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(isUserMassage ? 20 : 0),
                            bottomRight:
                                Radius.circular(isUserMassage ? 0 : 20),
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                          ),
                        ),
                        child: Container(
                          color: isUserMassage
                              ? Theme.of(context).primaryColor.withOpacity(.8)
                              : Colors.blueGrey.shade100,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _message.content,
                                style: TextStyle(
                                  color: isUserMassage
                                      ? Colors.white
                                      : Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                DateFormat('HH:mm')
                                    .format(_message.date)
                                    .toString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isUserMassage
                                      ? Colors.white70
                                      : Colors.blueGrey.withOpacity(.9),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
