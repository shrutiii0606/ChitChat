import 'package:chitchat/pages/chatroomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
        ),
        body: SafeArea(
          child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: searchcontroller,
                    decoration:
                        const InputDecoration(labelText: "Email Address"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {});
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text("Search"),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where("email", isEqualTo: searchcontroller.text)
                        .where("email", isNotEqualTo: widget.userModel.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          if (dataSnapshot.docs.isNotEmpty) {
                            Map<String, dynamic> userMap = dataSnapshot.docs[0]
                                .data() as Map<String, dynamic>;

                            UserModel searchedUser = UserModel.fromMap(userMap);
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ChatRoomPage();
                                }));
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(searchedUser.profilepic!),
                                backgroundColor: Colors.grey[500],
                              ),
                              title: Text(searchedUser.fullname.toString()),
                              subtitle: Text(
                                searchedUser.email.toString(),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                            );
                          } else {
                            return const Text("No results found");
                          }
                        } else if (snapshot.hasError) {
                          return const Text("An error occured");
                        } else {
                          return const Text("No results found");
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              )),
        ));
  }
}
