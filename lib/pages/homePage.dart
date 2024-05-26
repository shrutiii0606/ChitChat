import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'searchPage.dart';

class HomePage extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ChitChat"),
      ),
      body: SafeArea(
        child: Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
              userModel: userModel,
              firebaseUser: firebaseUser,
            );
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
