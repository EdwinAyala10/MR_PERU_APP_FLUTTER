import 'dart:convert';

class Message {
  final String senderName;
  final String content;
  final List<String>? markedsID;
  final String userID;
  final DateTime date;

  const Message({
    required this.senderName,
    required this.content,
    required this.date,
    this.markedsID,
    required this.userID,
  });

  bool isUserMessage(String senderName) => this.senderName == senderName;

  String toJson() => json.encode(
        {
          'senderName': senderName,
          'markedsID': markedsID,
          'userID': userID,
          'content': content,
          'date': date.toString(),
        },
      );

  static Message fromJson(Map<String, dynamic> data) {
    return Message(
      senderName: data['senderName'],
      content: data['content'],
      date: DateTime.parse(
        data['date'],
      ),
      markedsID: data['markedsID'] ?? [],
      userID: data['userID'],
    );
  }
}
