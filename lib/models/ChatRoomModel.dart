class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? lastupdated;

  ChatRoomModel(
      {this.chatroomid,
      this.participants,
      this.lastMessage,
      this.users,
      this.lastupdated});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    users = map["users"];
    lastupdated = map["lastupdated"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "users": users,
      "lastupdated": lastupdated,
    };
  }
}
