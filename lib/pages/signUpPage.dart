import 'package:chitchat/models/UserModel.dart';
import 'package:chitchat/pages/completeProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cpassword == "") {
      print("please fill all the fields");
    } else if (password != cpassword) {
      print("Passwords don not match");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newuser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        print("new user created");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              usermodel: newuser, firebaseUser: credential!.user!);
        }));
      });
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
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cpasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: " Confirm Password"),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Sign Up"),
              )
            ]),
          )),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Log In",
                style: TextStyle(
                  fontSize: 16,
                )),
          )
        ],
      ),
    );
  }
}
