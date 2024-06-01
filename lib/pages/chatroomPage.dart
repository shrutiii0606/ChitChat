import 'package:chitchat/models/ChatRoomModel.dart';
import 'package:chitchat/models/MessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage(
      {super.key,
      required this.targetuser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendmessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      //send message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetuser.profilepic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetuser.fullname.toString()),
          ]),
        ),
        body: SafeArea(
          child: Container(
              child: Column(
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(widget.chatroom.chatroomid)
                          .collection('messages')
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentmsg = MessageModel.fromMap(
                                    dataSnapshot.docs[index].data()
                                        as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: (currentmsg.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: (currentmsg.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          currentmsg.text.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                  ],
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  "An error has occurred! Please check your internet connection"),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "Say hi to your new friend",
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    )),
              ),
              Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message",
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            sendmessage();
                          },
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          ))
                    ],
                  ))
            ],
          )),
        ));
  }
}
