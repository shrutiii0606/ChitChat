import 'package:chitchat/models/ChatRoomModel.dart';
import 'package:chitchat/models/UIhelper.dart';
import 'package:chitchat/models/firebaseHelper.dart';
import 'package:chitchat/pages/chatroomPage.dart';
import 'package:chitchat/pages/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'searchPage.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ChitChat"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const LoginPage();
              }));
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("users", arrayContains: widget.userModel.uid)
              // .orderBy("lastcontact")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatroomsnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: chatroomsnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatroommodel = ChatRoomModel.fromMap(
                        chatroomsnapshot.docs[index].data()
                            as Map<String, dynamic>);
                    Map<String, dynamic>? participants =
                        chatroommodel.participants;
                    List<String> participantkeys = participants!.keys.toList();
                    participantkeys.remove(widget.userModel.uid);
                    return FutureBuilder(
                      future:
                          firebaseHelper.getUserModelById(participantkeys[0]),
                      builder: (context, userdata) {
                        if (userdata.connectionState == ConnectionState.done) {
                          if (userdata.data != null) {
                            UserModel targetuser = userdata.data as UserModel;

                            return ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomPage(
                                        targetuser: targetuser,
                                        chatroom: chatroommodel,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser);
                                  },
                                ));
                              },
                              title: Text(targetuser.fullname.toString()),
                              subtitle: (chatroommodel.lastMessage.toString() !=
                                      "")
                                  ? Text(chatroommodel.lastMessage.toString())
                                  : Text(
                                      "Say hi to your new friend",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    targetuser.profilepic.toString()),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text("No chats"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            );
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
