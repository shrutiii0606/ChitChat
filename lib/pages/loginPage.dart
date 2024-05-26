import 'package:chitchat/models/UserModel.dart';
import 'package:chitchat/pages/signUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import './homePage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  void checkValues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    if (email == '' || password == '') {
      print("Please Fill all the details");
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("hello");
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
              child: SingleChildScrollView(
            child: Column(children: [
              Text(
                "Chitchat",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: emailcontroller,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordcontroller,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Log In"),
              ),
            ]),
          )),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SignUpPage();
              }));
            },
            child: const Text("Sign Up",
                style: TextStyle(
                  fontSize: 16,
                )),
          )
        ],
      ),
    );
  }
}
