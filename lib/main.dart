import 'package:chitchat/models/firebaseHelper.dart';
import 'package:chitchat/pages/homePage.dart';
import 'package:chitchat/pages/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel =
        await firebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chitchat',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chitchat',
        debugShowCheckedModeBanner: false,
        home: HomePage(userModel: userModel, firebaseUser: firebaseUser));
  }
}
